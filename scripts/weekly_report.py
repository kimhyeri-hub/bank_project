"""
매주 월요일 오전 9시 실행: 프로젝트 진행률 자동 보고서 생성
"""

import os
import re
import glob
from datetime import datetime

PROJECT_DIR = r'C:/Users/hyyyr/claude_project'
SUMMARIES_DIR = os.path.join(PROJECT_DIR, 'summaries')


def count_checkboxes(text: str) -> tuple[int, int]:
    done = len(re.findall(r'- \[x\]', text, re.IGNORECASE))
    todo = len(re.findall(r'- \[ \]', text))
    return done, todo


def extract_status_keywords(text: str) -> list[str]:
    patterns = {
        '완료': r'완료|done|finished|✅',
        '진행중': r'진행중|in progress|wip|🔄',
        '대기': r'대기|pending|todo|⏳',
        '차단됨': r'차단|blocked|🚫',
    }
    found = []
    for label, pattern in patterns.items():
        count = len(re.findall(pattern, text, re.IGNORECASE))
        if count:
            found.append(f'{label}: {count}건')
    return found


def analyze_file(path: str) -> dict:
    try:
        with open(path, encoding='utf-8') as f:
            text = f.read()
    except Exception:
        return None

    done, todo = count_checkboxes(text)
    total = done + todo
    pct = round(done / total * 100) if total else 0
    status = extract_status_keywords(text)

    return {
        'path': path,
        'done': done,
        'todo': todo,
        'total': total,
        'pct': pct,
        'status': status,
    }


def main():
    os.makedirs(SUMMARIES_DIR, exist_ok=True)
    today = datetime.now().strftime('%Y%m%d')
    out_path = os.path.join(SUMMARIES_DIR, f'weekly_report_{today}.md')

    md_files = glob.glob(os.path.join(PROJECT_DIR, '**', '*.md'), recursive=True)
    md_files = [f for f in md_files if 'summaries' not in f.replace('\\', '/')]

    results = [r for f in md_files if (r := analyze_file(f))]
    results.sort(key=lambda r: -r['pct'])

    total_done = sum(r['done'] for r in results)
    total_items = sum(r['total'] for r in results)
    overall_pct = round(total_done / total_items * 100) if total_items else 0

    lines = [
        f'# 주간 진행률 보고서',
        f'> 생성: {datetime.now().strftime("%Y-%m-%d %H:%M")} (매주 월요일 자동)',
        '',
        f'## 전체 진행률: {overall_pct}% ({total_done}/{total_items})',
        '',
        '```',
        f'[{"█" * (overall_pct // 5)}{"░" * (20 - overall_pct // 5)}] {overall_pct}%',
        '```',
        '',
        '## 파일별 현황',
        '',
    ]

    if results:
        for r in results:
            rel = os.path.relpath(r['path'], PROJECT_DIR).replace('\\', '/')
            bar_filled = r['pct'] // 10
            bar = '█' * bar_filled + '░' * (10 - bar_filled)
            status_str = '  ' + ' / '.join(r['status']) if r['status'] else ''
            lines.append(f'### {rel}')
            lines.append(f'- 진행률: `[{bar}]` **{r["pct"]}%** ({r["done"]}/{r["total"]}){status_str}')
            lines.append(f'- 완료: {r["done"]}개  |  미완료: {r["todo"]}개')
            lines.append('')
    else:
        lines.append('> 체크박스가 있는 파일이 없습니다.')

    # 주간 요약 한 줄
    if overall_pct >= 80:
        summary = f'이번 주 진행률 {overall_pct}% — 목표 달성 근접. 남은 {total_items - total_done}개 항목 마무리 권장.'
    elif overall_pct >= 50:
        summary = f'이번 주 진행률 {overall_pct}% — 순조롭게 진행 중. {total_done}/{total_items} 완료.'
    else:
        summary = f'이번 주 진행률 {overall_pct}% — 집중 필요. 미완료 {total_items - total_done}개 항목 우선 처리 권장.'

    lines += ['---', f'**주간 요약:** {summary}', '']

    with open(out_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    print(f'[weekly_report] saved → {out_path}')


if __name__ == '__main__':
    main()
