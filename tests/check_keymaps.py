#!/usr/bin/env python3
"""Check literal first-party leader mappings without executing configuration.

Lua comments and strings are lexed, lazy key specs and direct keymap/map calls
are recognized, and modes form part of the identity. Dynamic/plugin-generated
mappings and conditional runtime activation still require editor verification.
"""
import collections
import re
import sys
from pathlib import Path


def tokens(text):
    out = []
    i = 0
    line = 1
    while i < len(text):
        if text[i].isspace():
            line += text[i] == '\n'
            i += 1
            continue
        comment = text.startswith('--', i)
        start = i + 2 if comment else i
        long = re.match(r'\[(=*)\[', text[start:])
        if long:
            endmark = ']' + long[1] + ']'
            end = text.find(endmark, start + len(long[0]))
            if end < 0:
                raise ValueError(f'unterminated long string/comment at line {line}')
            end += len(endmark)
            if not comment:
                out.append(('string', text[start + len(long[0]):end - len(endmark)], line))
            line += text[i:end].count('\n')
            i = end
        elif comment:
            end = text.find('\n', i)
            i = len(text) if end < 0 else end
        elif text[i] in "\"'":
            quote = text[i]
            startline = line
            i += 1
            value = ''
            while i < len(text) and text[i] != quote:
                if text[i] == '\\':
                    i += 1
                    if i == len(text):
                        raise ValueError('unterminated escape')
                value += text[i]
                line += text[i] == '\n'
                i += 1
            if i == len(text):
                raise ValueError(f'unterminated string at line {startline}')
            i += 1
            out.append(('string', value, startline))
        else:
            match = re.match(r'[A-Za-z_][A-Za-z_0-9]*', text[i:])
            value = match[0] if match else text[i]
            out.append(('word' if match else 'symbol', value, line))
            i += len(value)
    return out


def group(ts, start):
    closing = {'{': '}', '(': ')', '[': ']'}
    stack = [closing[ts[start][1]]]
    for j in range(start + 1, len(ts)):
        if ts[j][0] == 'symbol':
            value = ts[j][1]
            if value in closing:
                stack.append(closing[value])
            elif value == stack[-1]:
                stack.pop()
                if not stack:
                    return j
    raise ValueError(f'unclosed group at line {ts[start][2]}')


def modes(ts):
    strings = [t[1] for t in ts if t[0] == 'string']
    if not strings or any(m not in {'n', 'v', 'x', 's', 'i', 't', 'c', 'o', ''} for m in strings):
        raise ValueError('mapping mode is not a supported literal')
    # v maps visual and select, x is visual only, empty maps n/v/o.
    return set(x for m in strings for x in ({'x', 's'} if m == 'v' else {'n', 'x', 's', 'o'} if m == '' else {m}))


def mappings(text):
    ts = tokens(text)
    result = []
    for i, token in enumerate(ts):
        # Lazy's literal { '<leader>key', rhs, mode = ... } spec.
        if token[1] == '{' and i + 2 < len(ts) and ts[i + 1][0] == 'string' and ts[i + 1][1].startswith('<leader>') and ts[i + 2][1] == ',':
            end = group(ts, i)
            ms = {'n'}
            j = i + 2
            while j < end:
                if ts[j][1] in {'{', '(', '['}:
                    j = group(ts, j) + 1
                    continue
                if ts[j][1] == 'mode' and ts[j + 1][1] == '=':
                    k = j + 2
                    mode_end = group(ts, k) + 1 if ts[k][1] == '{' else k + 1
                    ms = modes(ts[k:mode_end])
                j += 1
            result.extend((m, ts[i + 1][1], ts[i + 1][2]) for m in ms)
        # Calls with literal modes: vim.keymap.set(...) and the gitsigns map helper.
        is_direct = [t[1] for t in ts[i:i + 6]] == ['vim', '.', 'keymap', '.', 'set', '(']
        is_helper = token[1] == 'map' and i + 1 < len(ts) and ts[i + 1][1] == '(' and (i == 0 or ts[i - 1][1] != 'function')
        if not (is_direct or is_helper):
            continue
        start = i + (6 if is_direct else 2)
        if ts[start][0] == 'string':
            end = start + 1
        elif ts[start][1] == '{':
            end = group(ts, start) + 1
        else:
            continue  # dynamic wrapper definition; its literal call sites are checked
        if end + 1 < len(ts) and ts[end][1] == ',' and ts[end + 1][0] == 'string' and ts[end + 1][1].startswith('<leader>'):
            result.extend((m, ts[end + 1][1], ts[end + 1][2]) for m in modes(ts[start:end]))
    return result


def main():
    if len(sys.argv) == 4 and sys.argv[2] == '--plugin':
        count = sum(1 for p in Path(sys.argv[1]).rglob('*.lua') for kind, value, _ in tokens(p.read_text()) if kind == 'string' and value.endswith('/' + sys.argv[3]))
        print(f'{sys.argv[3]} literal repository declarations: {count}')
        return count != 1
    seen = collections.defaultdict(list)
    for path in sorted(Path(sys.argv[1]).rglob('*.lua')):
        for mode, key, line in mappings(path.read_text()):
            seen[mode, key].append(f'{path}:{line}')
    duplicates = {k: v for k, v in seen.items() if len(v) > 1}
    for (mode, key), paths in sorted(duplicates.items()):
        print(f'Duplicate {mode} {key}: ' + ', '.join(paths))
    print(f'Checked {len(seen)} literal leader/mode identities; dynamic runtime maps require editor verification.')
    return bool(duplicates)


if __name__ == '__main__':
    sys.exit(main())
