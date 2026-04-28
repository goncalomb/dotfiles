#!/usr/bin/env python3

import os
import re
import tomllib

os.chdir(os.path.dirname(__file__))

PEP_723_REGEX = r'(?m)^# /// (?P<type>[a-zA-Z0-9-]+)$\s(?P<content>(^#(| .*)$\s)+)^# ///$'


def read_pep723(script: str, name: str = 'script'):
    # Based on PEP 723 reference implementation:
    # https://peps.python.org/pep-0723/
    # https://packaging.python.org/en/latest/specifications/inline-script-metadata/
    matches = list(
        filter(lambda m: m.group('type') == name, re.finditer(PEP_723_REGEX, script))
    )
    if len(matches) > 1:
        raise ValueError(f'Multiple {name} blocks found')
    elif len(matches) == 1:
        content = ''.join(
            line[2:] if line.startswith('# ') else line[1:]
            for line in matches[0].group('content').splitlines(keepends=True)
        )
        return tomllib.loads(content)
    else:
        return None


def read_file_pep723(path: str, name: str = 'script'):
    with open(path, 'r') as f:
        return read_pep723(f.read(), name)


def read_file_meta(path: str):
    meta = read_file_pep723(path, 'dotfiles')
    if not meta:
        print(f"Warning: No metadata found for '{path}'.")
        meta = {}
    description = meta.get('description', '')
    tags = meta.get('tags', [])
    year = meta.get('year', '')
    flags = []
    if 'caution' in tags:
        flags.append('\\[**!**\\]')
    if 'unknown' in tags:
        flags.append('\\[**?**\\]')
    if 'disabled' in tags:
        flags.append('\\[**X**\\]')
    return {
        'description': description,
        'tags': tags,
        'year': year,
        'description_md': f'{''.join(flags) + ' ' if flags else ''}{description or '-'}',
        'tags_md': ', '.join(tags) or '-',
        'year_md': year[-4:] or '-',
    }


def read_scripts_directory_pep723(directory: str):
    result = []
    for f in os.listdir(directory):
        path = os.path.join(directory, f)
        if os.path.isfile(path):
            f_meta = read_file_meta(path)
            result.append((path, f, f_meta))
    result.sort(key=lambda x: x[1])
    return result


def make_scripts_table(dirs: str):
    scripts = (s for d in dirs for s in read_scripts_directory_pep723(d))
    columns = ['Scripts', 'Description', 'Tags', 'Updated']
    header = ' | '.join(columns) + '\n'
    table = [header, ' | '.join('-' * len(col) for col in columns) + '\n']
    for path, name, meta in scripts:
        link = f'[{name}]({path})'
        table.append(f'{link} | {meta['description_md']} | {meta['tags_md']} | {meta['year_md']}\n')
    return header, table


def update_lines(lines: list, after: str, start: str, content: list, end: str = '\n'):
    try:
        i = lines.index(after)
        j = lines.index(start, i + 1)
    except ValueError:
        print(f"Error: Could not find '{after.strip()}' or '{start.strip()}', not updated.")
        return lines
    try:
        k = lines.index(end, j + 1)
        return lines[:j] + content + lines[k:]
    except ValueError:
        return lines[:j] + content


def update_file_list_lines(lines: list):
    REGEX = r'^\* \[([^\]]+)\]\(([^)]+)\):'
    result = list(lines)
    for i, line in enumerate(lines):
        match = re.match(REGEX, line)
        if match and match.group(1) == match.group(2):
            name = match.group(1)
            if os.path.isfile(name):
                link = f'[{name}]({name})'
                meta = read_file_meta(name)
                result[i] = f'* {link}: {meta['description_md']}\n'
    return result


if __name__ == '__main__':
    bin_header, bin_table = make_scripts_table(['bin', 'bin_termux'])
    with open('README.md', 'r+') as fp:
        lines = fp.readlines()
        lines = update_lines(lines, '### Scripts (`bin/`)\n', bin_header, bin_table)
        lines = update_file_list_lines(lines)
        fp.seek(0)
        fp.writelines(lines)
        fp.truncate()
