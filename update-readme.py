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


def read_scripts_directory_pep723(directory: str):
    result = []
    for f in os.listdir(directory):
        path = os.path.join(directory, f)
        if os.path.isfile(path):
            f_metadata = read_file_pep723(path, 'dotfiles')
            result.append((path, f, f_metadata))
    result.sort(key=lambda x: x[1])
    return result


def make_scripts_table(directory: str):
    scripts = read_scripts_directory_pep723(directory)
    columns = ['Scripts', 'Description', 'Tags', 'Updated']
    header = ' | '.join(columns) + '\n'
    table = [header, ' | '.join('-' * len(col) for col in columns) + '\n']
    for path, name, metadata in scripts:
        link = f'[{name}]({path})'
        if metadata:
            description = metadata.get('description', '-')
            tags = ', '.join(metadata.get('tags', [])) or '-'
            year = metadata.get('year', '')[-4:] or '-'
            table.append(f'{link} | {description} | {tags} | {year}\n')
        else:
            print(f"Warning: No metadata found for '{path}'.")
            table.append(f'{link} | - | - | -\n')
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


if __name__ == '__main__':
    bin_header, bin_table = make_scripts_table('bin')
    with open('README.md', 'r+') as fp:
        lines = fp.readlines()
        lines = update_lines(lines, '### Scripts\n', bin_header, bin_table)
        fp.seek(0)
        fp.writelines(lines)
        fp.truncate()
