import os
import glob
from datetime import datetime

PROJECT_DIR = r'C:/Users/hyyyr/claude_project'
SUMMARIES_DIR = os.path.join(PROJECT_DIR, 'summaries')

KEYWORDS = [
    '회의', '회의록', '결정', '결정사항', '합의', '논의', '논의사항',
    'action item', '액션', '할일', '다음 단계',
    'meeting', 'decision', 'decided', 'agreed',
]


def score_line(line: str) -> bool:
    low = line.lower()
    return any(kw.lower() in low for kw in KEYWORDS)


def extract_from_file(path: str) -> list[dict]:
    try:
        with open(path, encoding='utf-8') as f:
            lines = f.readlines()
    except Exception:
        return []

    hits = []
    for i, line in enumerate(lines):
        if score_line(line):
            ctx_start = max(0, i - 1)
            ctx_end = min(len(lines), i + 3)
            hits.append({
                'line_num': i + 1,
                'context': ''.join(lines[ctx_start:ctx_end]).rstrip(),
            })
    return hits


def main():
    os.makedirs(SUMMARIES_DIR, exist_ok=True)
    today = datetime.now().strftime('%Y%m%d')
    out_path = os.path.join(SUMMARIES_DIR, f'meeting_notes_{today}.md')

    md_files = glob.glob(os.path.join(PROJECT_DIR, '**', '*.md'), recursive=True)
    md_files = [f for f in md_files if 'summaries' not in f.replace('\\', '/')]

    sections: list[str] = []
    for md_file in sorted(md_files):
        hits = extract_from_file(md_file)
        if not hits:
            continue
        rel = os.path.relpath(md_file, PROJECT_DIR).replace('\\', '/')
        block = [f'\n## {rel}\n']
        for hit in hits:
            block.append(f'**Line {hit["line_num"]}:**\n```\n{hit["context"]}\n```\n')
        sections.append('\n'.join(block))

    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(f'# 회의록 / 결정사항 요약\n')
        f.write(f'> 생성: {datetime.now().strftime("%Y-%m-%d %H:%M")}\n\n')
        if sections:
            f.write('\n'.join(sections))
        else:
            f.write('> 회의 관련 내용이 발견되지 않았습니다.\n')

    print(f'[organize] saved → {out_path}')


if __name__ == '__main__':
    main()
