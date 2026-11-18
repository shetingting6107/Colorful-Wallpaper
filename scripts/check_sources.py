# -*- coding: utf-8 -*-
"""Static sanity check: brace balance + data integrity for the Flutter project."""
import glob
import json
import os
import re

files = glob.glob('lib/**/*.dart', recursive=True) + \
    glob.glob('android/**/*.java', recursive=True) + \
    glob.glob('ios/**/*.swift', recursive=True) + \
    ['pubspec.yaml', 'analysis_options.yaml', 'README.md', 'assets/colors.json']

print(f'{len(files)} files')
issues = []
for f in files:
    src = open(f, encoding='utf-8').read()
    if f.endswith(('.dart', '.java', '.swift')):
        s = re.sub(r'//.*', '', src)
        s = re.sub(r"'(\\.|[^'\\])*'", "''", s)
        s = re.sub(r'"(\\.|[^"\\])*"', '""', s)
        for a, b in [('{', '}'), ('(', ')'), ('[', ']')]:
            if s.count(a) != s.count(b):
                issues.append(f'{f}: {a}{b} mismatch {s.count(a)} vs {s.count(b)}')
    print(f'  {f}  {os.path.getsize(f)}B')

d = json.load(open('assets/colors.json', encoding='utf-8'))
assert len(d['colors']) == 60 and len(d['families']) == 8
ids = [c['id'] for c in d['colors']]
assert len(set(ids)) == 60
assert 'yuebai' in ids, 'default secondary color missing'
print('colors.json OK: 60 colors, 8 families, yuebai present')
print('ISSUES:', issues if issues else 'none')
