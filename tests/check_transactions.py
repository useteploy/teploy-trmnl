"""Real manager fault fixtures; only caller-supplied private evidence HOME is used."""
import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess
import sys

R = Path(__file__).resolve().parents[1]
O = Path(sys.argv[1]).resolve()
O.mkdir(mode=0o700, parents=True, exist_ok=True)
F = O / 'transaction-homes'
F.mkdir(mode=0o700)
ITEMS = ['nvim', 'zellij', 'yazi', 'starship.toml']
RESULTS = []


def snap(root):
    result = {}
    if not root.exists():
        return result
    for p in [root, *sorted(root.rglob('*'))]:
        st = p.lstat()
        key = str(p.relative_to(root))
        row = {'mode': oct(stat.S_IMODE(st.st_mode))}
        if p.is_symlink():
            row.update(type='link', target=os.readlink(p))
        elif p.is_file():
            row.update(type='file', sha256=hashlib.sha256(p.read_bytes()).hexdigest())
        else:
            row['type'] = 'dir'
        result[key] = row
    return result


def state(h, c):
    return {'config': snap(c), 'shell': snap_file(h / '.zshrc'), 'git': snap_file(h / '.gitconfig')}


def snap_file(p):
    return {'bytes': p.read_bytes().hex(), 'mode': oct(stat.S_IMODE(p.stat().st_mode))} if p.exists() else None


def home(label, kind='mixed'):
    h = F / label
    h.mkdir(mode=0o700)
    c = h / "custom config ' [x]"
    c.mkdir(mode=0o755)
    e = {'HOME': str(h), 'XDG_CONFIG_HOME': str(c), 'XDG_DATA_HOME': str(h / 'data'),
         'XDG_STATE_HOME': str(h / 'state'), 'XDG_CACHE_HOME': str(h / 'cache'),
         'TRMNL_DIR': str(R / 'config'), 'GIT_CONFIG_NOSYSTEM': '1',
         'PATH': '/usr/bin:/bin:/usr/sbin:/sbin', 'TRMNL_NO_AUTOLAUNCH': '1'}
    (h / '.zshrc').write_text('# KEEP shell\nexport TEST_LITERAL="a;$x"\n')
    (h / '.gitconfig').write_text('[user]\n name = KEEP\n[include]\n path = /foreign/git\n')
    (h / '.zshrc').chmod(0o644)
    (h / '.gitconfig').chmod(0o640)
    (h / 'foreign').mkdir(mode=0o755)
    (h / 'foreign/keep').write_text('FOREIGN')
    for i, item in enumerate(ITEMS):
        k = ['dir', 'relative', 'broken', 'file'][i] if kind == 'mixed' else kind
        p = c / item
        if k == 'dir':
            p.mkdir(mode=0o755)
            (p / 'nested').mkdir(mode=0o751)
            (p / 'nested/executable').write_text('EXECUTABLE')
            (p / 'nested/executable').chmod(0o755)
            (p / 'plain').write_text('BYTES')
            (p / 'plain').chmod(0o644)
            os.symlink('plain', p / 'relative')
            os.symlink('missing', p / 'broken')
        elif k == 'file':
            p.write_text('ORIGINAL ' + item)
            p.chmod(0o644)
        elif k == 'relative':
            os.symlink('../foreign', p)
        elif k == 'broken':
            os.symlink('missing-relative', p)
        elif k == 'foreign':
            os.symlink(str(h / 'foreign'), p)
        elif k == 'absent':
            pass
        else:
            raise ValueError(k)
    return h, c, e


def run(label, e, command, expected=0, extra=()):
    p = subprocess.run(['/bin/bash', str(R / 'bin/trmnl'), command, *extra], env=e,
                       input='y\n' if command == 'uninstall' else None, text=True,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=15)
    (O / (label + '.log')).write_text(p.stdout)
    assert (p.returncode == expected if expected is not None else p.returncode != 0), (label, p.returncode, p.stdout)
    return p


def shim(h, e, stage, item='', action='before', second=''):
    b = h / 'shims'
    b.mkdir(exist_ok=True)
    e.update(PATH=str(b) + ':/usr/bin:/bin:/usr/sbin:/sbin', FAULT_STAGE=stage,
             FAULT_ITEM=item, FAULT_ACTION=action, SECOND=second)
    (b / 'mv').write_text('''#!/bin/bash
hit=false
case "$FAULT_STAGE" in
 displace) [ "$1" = "$XDG_CONFIG_HOME/$FAULT_ITEM" ] && [[ "$2" == */targets/"$FAULT_ITEM" ]] && hit=true ;;
 journal-displace) [ "$1" = "$XDG_CONFIG_HOME/.trmnl-links" ] && hit=true ;;
 journal-publish) [[ "$1" == */journal ]] && [ "$2" = "$XDG_CONFIG_HOME/.trmnl-links" ] && hit=true ;;
 remove) [ "$1" = "$XDG_CONFIG_HOME/$FAULT_ITEM" ] && [[ "$2" == */removed-"$FAULT_ITEM" ]] && hit=true ;;
 restore) [ "$1" = "$XDG_CONFIG_HOME/.trmnl-links/$FAULT_ITEM/previous" ] && hit=true ;;
 retire) [ "$1" = "$XDG_CONFIG_HOME/.trmnl-links/$FAULT_ITEM" ] && [[ "$2" == */entries/"$FAULT_ITEM" ]] && hit=true ;;
 git|shell) name=gitconfig; [ "$FAULT_STAGE" != shell ] || name=zshrc
   [[ "$1" == */"$name" ]] && [ "$2" = "$HOME/.$name" ] && hit=true ;;
esac
if [ "$hit" = true ]; then
 case "$FAULT_ACTION" in
  before) exit 47 ;;
  after) /bin/mv "$@" || exit; exit 48 ;;
  signal-before) kill -TERM "$PPID"; exit 47 ;;
  signal-after) /bin/mv "$@" || exit; kill -TERM "$PPID"; exit 0 ;;
 esac
fi
case "$SECOND" in
 target) [[ "$1" == */targets/* || "$1" == */removed-* ]] && exit 49 ;;
 previous) [ "$2" = "$XDG_CONFIG_HOME/nvim/previous" ] && exit 49
   [ "$2" = "$XDG_CONFIG_HOME/.trmnl-links/nvim/previous" ] && exit 49 ;;
 entry) [[ "$1" == */entries/nvim ]] && exit 49 ;;
 git) [[ "$1" == */recover-gitconfig ]] && exit 49 ;;
 shell) [[ "$1" == */recover-zshrc ]] && exit 49 ;;
 journal) [[ "$1" == */journal-before ]] && exit 49 ;;
esac
exec /bin/mv "$@"
''')
    (b / 'mv').chmod(0o700)


def verify(label, before, h, c, p):
    after = state(h, c)
    assert after == before, (label, before, after, p.stdout)
    assert not list(h.glob('.trmnl-setup.*')) and not list(h.glob('.trmnl-uninstall.*')), label
    RESULTS.append({'case': label, 'exit': p.returncode, 'exact_before_state': True})


# Each target, every predecessor type, failed command before and after mutation.
for kind in ['owned', 'foreign', 'broken', 'relative', 'file', 'dir']:
    for item in ITEMS:
        for action in ['before', 'after']:
            label = f'setup-{kind}-{item}-{action}'
            h, c, e = home(label, 'mixed' if kind == 'owned' else kind)
            if kind == 'owned':
                run(label + '-first', e, 'setup')
            before = state(h, c)
            shim(h, e, 'displace', item, action)
            p = run(label, e, 'setup', None)
            verify(label, before, h, c, p)

# Signal windows on both sides of each displacement, journal and file publication.
for stage, items in [('displace', ITEMS), ('journal-displace', ['']), ('journal-publish', ['']), ('git', ['']), ('shell', [''])]:
    for item in items:
        for action in ['signal-before', 'signal-after']:
            label = f'setup-{stage}-{item}-{action}'
            h, c, e = home(label)
            run(label + '-first', e, 'setup')
            before = state(h, c)
            shim(h, e, stage, item, action)
            p = run(label, e, 'setup', None)
            verify(label, before, h, c, p)

# Modes/content/types are compared after repeat setup and successful uninstall.
for kind in ['mixed', 'dir', 'file', 'absent']:
    label = 'modes-repeat-' + kind
    h, c, e = home(label, kind)
    before = state(h, c)
    run(label + '-first', e, 'setup')
    first = state(h, c)
    assert stat.S_IMODE((c / '.trmnl-links').stat().st_mode) == 0o700
    run(label + '-repeat', e, 'setup')
    assert state(h, c) == first
    run(label, e, 'uninstall')
    # The deliberately retained empty private journal root is the only addition.
    (c / '.trmnl-links').rmdir()
    assert state(h, c) == before
    RESULTS.append({'case': label, 'modes_bytes_symlinks_preserved': True})

# Physical copy failures before and after partial output never consume originals.
for action in ['before', 'after']:
    label = 'copy-' + action
    h, c, e = home(label)
    before = state(h, c)
    b = h / 'shims'; b.mkdir()
    e['PATH'] = str(b) + ':' + e['PATH']
    (b / 'cp').write_text('''#!/bin/bash
if [ "$2" = "$XDG_CONFIG_HOME/nvim" ]; then
''' + ('/bin/cp "$@" || exit\n' if action == 'after' else '') + '''exit 46
fi
exec /bin/cp "$@"
''')
    (b / 'cp').chmod(0o700)
    p = run(label, e, 'setup', None)
    verify(label, before, h, c, p)

for stage, items in [('remove', ITEMS), ('restore', ITEMS), ('retire', ITEMS), ('git', ['']), ('shell', [''])]:
    for item in items:
        for action in ['before', 'after', 'signal-before', 'signal-after']:
            label = f'uninstall-{stage}-{item}-{action}'
            h, c, e = home(label)
            run(label + '-first', e, 'setup')
            before = state(h, c)
            shim(h, e, stage, item, action)
            p = run(label, e, 'uninstall', None)
            verify(label, before, h, c, p)
            e['FAULT_STAGE'] = ''
            run(label + '-retry', e, 'uninstall')

# Second recovery errors must retain material; retries restore the entire state.
for command, second in [('setup', 'target'), ('setup', 'journal'), ('setup', 'git'), ('setup', 'shell'),
                        ('uninstall', 'target'), ('uninstall', 'previous'), ('uninstall', 'entry'),
                        ('uninstall', 'git'), ('uninstall', 'shell')]:
    label = command + '-second-error-' + second
    h, c, e = home(label)
    run(label + '-first', e, 'setup')
    before = state(h, c)
    action = 'after' if second == 'shell' else 'before'
    shim(h, e, 'shell', action=action, second=second)
    p = run(label, e, command, None)
    pending = list(h.glob('.trmnl-' + command + '.*'))
    assert len(pending) == 1 and 'Recovery incomplete' in p.stdout, (label, p.stdout)
    assert stat.S_IMODE(pending[0].stat().st_mode) == 0o700
    pending_state = state(h, c)
    run(label + '-pending-setup', e, 'setup', None)
    run(label + '-pending-uninstall', e, 'uninstall', None)
    assert state(h, c) == pending_state
    # A repeated failed recovery still retains the recovery tree.
    run(label + '-recover-fails', e, 'recover', None, [str(pending[0])])
    assert pending[0].exists()
    e['FAULT_STAGE'] = ''; e['SECOND'] = ''
    run(label + '-recover', e, 'recover', 0, [str(pending[0])])
    verify(label, before, h, c, p)
    run(label + '-retry', e, command)

(O / 'transaction-results.json').write_text(json.dumps({'cases': RESULTS, 'count': len(RESULTS), 'all_pass': True}, indent=2) + '\n')
print(json.dumps({'cases': len(RESULTS), 'all_pass': True}))
