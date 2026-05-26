"""
Stop hook: 대화 종료 시 트랜스크립트에서 불확실/미해결 영역을 추출해
summaries/questions_YYYYMMDD.md 에 누적 저장.
"""

import json
import os
import glob
import sys
from datetime import datetime
from pathlib import Path

PROJECT_DIR = r'C:/Users/hyyyr/claude_project'
SUMMARIES_DIR = os.path.join(PROJECT_DIR, 'summaries')

UNCERTAINTY_PATTERNS = [
    # 한국어
    '모르겠', '확인이 필요', '불명확', '알 수 없', '정확하지 않',
    '추가 조사', '불확실', '확인 필요', '검토 필요', '파악하지 못',
    '더 알아봐야', '추가 확인', '명확하지 않', '확인해야',
    # 영어
    "i'm not sure", "i don't know", "unclear", "need to verify",
    "not certain", "need to check", "to be confirmed", "tbd",
    "uncertain", "need more info",
]


def find_latest_transcript() -> str | None:
    base = Path.home() / '.claude' / 'projects'
    files = list(base.rglob('*.jsonl'))
    if not files:
        return None
    return str(max(files, key=lambda p: p.stat().st_mtime))


def extract_uncertain_sentences(transcript_path: str) -> list[dict]:
    results = []
    seen = set()

    try:
        with open(transcript_path, encoding='utf-8') as f:
            for raw in f:
                raw = raw.strip()
                if not raw:
                    continue
                try:
                    entry = json.loads(raw)
                except json.JSONDecodeError:
                    continue

                if entry.get('role') != 'assistant':
                    continue

                content = entry.get('content', '')
                if isinstance(content, list):
                    text = ' '.join(
                        block.get('text', '')
                        for block in content
                        if isinstance(block, dict) and block.get('type') == 'text'
                    )
                else:
                    text = str(content)

                low = text.lower()
                for pat in UNCERTAINTY_PATTERNS:
                    if pat not in low:
                        continue
                    # 해당 패턴이 포함된 문장 추출
                    for sentence in text.replace('\n', ' ').split('. '):
                        if pat in sentence.lower() and sentence.strip() not in seen:
                            seen.add(sentence.strip())
                            results.append({'pattern': pat, 'sentence': sentence.strip()[:300]})
                            break
    except Exception as e:
        results.append({'pattern': 'error', 'sentence': str(e)})

    return results


def main():
    os.makedirs(SUMMARIES_DIR, exist_ok=True)
    today = datetime.now().strftime('%Y%m%d')
    out_path = os.path.join(SUMMARIES_DIR, f'questions_{today}.md')

    transcript = find_latest_transcript()
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')

    with open(out_path, 'a', encoding='utf-8') as f:
        f.write(f'\n## 세션 종료 — {timestamp}\n\n')

        if not transcript:
            f.write('> 트랜스크립트를 찾을 수 없습니다.\n')
            return

        items = extract_uncertain_sentences(transcript)

        if not items:
            f.write('> 이번 세션에서 불확실 영역이 감지되지 않았습니다.\n')
        else:
            f.write('### 추가 확인이 필요한 영역\n\n')
            for item in items:
                f.write(f'- [ ] `{item["pattern"]}` — {item["sentence"]}\n')

    print(f'[questions] saved → {out_path}')


if __name__ == '__main__':
    main()
