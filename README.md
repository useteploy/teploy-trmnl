# trmnl — Terminal IDE

A preconfigured terminal development environment built on Neovim, Zellij, and modern CLI tools.

## Install

### macOS & Linux

```bash
brew tap useteploy/tap
brew install trmnl
trmnl setup
source ~/.zshrc
```

### Windows (via WSL)

```bash
wsl --install
# Inside WSL:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew tap useteploy/tap
brew install trmnl
trmnl setup
```

## What's Included

### Core

- **Neovim** with 50+ language servers, autocompletion (blink.cmp), formatting (conform), debugging (nvim-dap), and testing (neotest)
- **Zellij** as the multiplexer with a dev layout and custom keybinds
- **Yazi** for file management
- **Lazygit** for git workflows
- **Harpoon** for quick file jumping
- **CodeCompanion** for AI assistance (Claude API)
- **Tokyo Night** theme across all tools

### CLI Tools

bat, eza, delta, starship, fzf, zoxide, ripgrep, fd, btop, tldr, gh, jq

### API & Database Clients

- **atac** — TUI API client (Postman-style, git-friendly collections)
- **hurl** — plain-text HTTP requests and assertions, request-as-code for CI
- **lazysql** — TUI database client (browse/query Postgres, MySQL, SQLite)

### Shell Integration

Aliases, project scaffolding functions (Go, Rust, Node, Python), profiling shortcuts, and Docker/Kubernetes helpers. See `config/zshrc-block` for the full list.

## Quick Start

```bash
trmnl              # Launch (auto-starts Zellij)
trmnl keys         # Show keybind cheatsheet
trmnl doctor       # Check installation health
trmnl setup        # Re-run setup
trmnl uninstall    # Remove config symlinks
```

## Keybinds

### Zellij

| Mode | Key | Action |
|------|-----|--------|
| Pane | `Ctrl+p` | Enter pane mode |
| | `a/r/d/b` | New pane left/right/down/bottom |
| | `h/j/k/l` | Move focus |
| | `f` | Toggle fullscreen |
| | `x` | Close pane |
| Tab | `Ctrl+t` | Enter tab mode |
| | `n` | New tab |
| | `1-9` | Jump to tab |
| Resize | `Ctrl+n` | Enter resize mode |
| Scroll | `Ctrl+s` | Enter scroll mode |
| Session | `Ctrl+o` | Enter session mode |
| Quit | `Ctrl+q` | Quit Zellij (drops to a normal shell) |

#### Exiting Zellij

Zellij auto-starts in interactive shells. To leave it, press `Ctrl+q` (or run `exit` until the last pane closes) — you'll land back in a normal shell prompt instead of the terminal closing. Run `zellij` to re-enter.

To stop the auto-launch entirely, set `TRMNL_NO_AUTOLAUNCH=1` (e.g. `export TRMNL_NO_AUTOLAUNCH=1` before opening a shell, or add it to your `~/.zshrc` above the trmnl block).

#### Neovim pass-through (autolock)

A bundled headless plugin ([`zellij-autolock`](https://github.com/fresh2dev/zellij-autolock)) keeps Zellij's hotkeys from clobbering Neovim. When the focused pane runs `nvim`/`vim`/`fzf`/`lazygit`/`yazi`/`less`/`man`/`git`, Zellij auto-switches to **locked** mode, so every `Ctrl` key (`Ctrl+o` jumplist, `Ctrl+p`/`Ctrl+n` completion, `Ctrl+t` tags, `Ctrl+b` page-up, ...) goes straight to that program. Back in a shell pane it unlocks and the direct hotkeys above work again.

To run a Zellij action *over* a Neovim pane: press `Ctrl+g` to take manual control (disables autolock + unlocks), do your thing (e.g. `Ctrl+p` then `x` to close the pane), then `Ctrl+g` again to hand control back to autolock.

### Neovim

| Key | Action |
|-----|--------|
| `Space sf` | Find files |
| `Space sg` | Grep search |
| `Space /` | Search current buffer |
| `\` | Toggle neo-tree |
| `Space gg` | Open lazygit |
| `Ctrl+\` | Floating terminal |
| `Space f` | Format buffer |
| `Space u` | Undo tree |
| `Space xx` | Diagnostics |
| `s` / `S` | Flash jump / treesitter |
| `Space ma` | Harpoon add file |
| `Space mm` | Harpoon menu |
| `Space m1-5` | Jump to harpoon mark |
| `F5` | Debug start/continue |
| `Space db` | Toggle breakpoint |
| `Shift+h/l` | Prev/next buffer |

## Configuration

All config is symlinked from the installation into `${XDG_CONFIG_HOME:-$HOME/.config}/`:

- `nvim/` — Neovim (Kickstart-based)
- `zellij/` — Multiplexer
- `yazi/` — File manager
- `starship.toml` — Prompt

Setup validates source files before changing configuration. Previous files, directories and symlinks are retained in `${XDG_CONFIG_HOME:-$HOME/.config}/.trmnl-links/`; uninstall restores a predecessor only while its destination still points at the recorded trmnl target. User replacements are preserved, with unresolved backups retained in the journal. Setup refuses symlinked `.zshrc`/`.gitconfig` rather than replacing dotfiles-manager links; integrate these files manually in that case. Run setup/uninstall one at a time. Ordinary command failures and HUP/INT/TERM restore pre-operation links, journal entries, shell and Git configuration. If recovery encounters another error, the manager prints the retained private transaction path. Resolve the filesystem error, then run `trmnl recover /absolute/printed/path` with the same HOME, XDG_CONFIG_HOME and TRMNL_DIR before retrying setup/uninstall. Recovery retries retain their material until restoration succeeds.

Predecessor copies use physical `cp -pRP` to preserve file/directory access modes (including nested executable bits), bytes and ordinary/broken symlinks. The journal root remains private (0700). Ownership, ACLs and extended attributes are not guaranteed across supported platforms/filesystems; copy failures abort setup without consuming the original. These are ordinary-error and catchable-signal recovery guarantees under serial use, not an fsync/power-loss or SIGKILL transaction. Concurrent external edits are outside this guarantee.

The dependency-free manager fault fixtures can be run with `python3 tests/check_transactions.py /absolute/private/evidence-directory`. They execute the actual manager using private HOME/XDG trees, inspect bytes/types/modes and inject move/copy/publication/signal/recovery failures; they do not load editor plugins or run the vendored WASM.

Git config is added as an exact `[include]` in your existing `~/.gitconfig`. Setup atomically replaces one delimited shell block, including a guarded `$HOME/.local/bin` PATH entry. Malformed delimiters are rejected. `trmnl doctor` exits 1 when required tools/configuration are missing or a required tool's version command fails; optional font/terminal warnings remain nonfatal.

The standalone installer stages and checks configuration and launcher files before replacing the installed tree. It rolls back ordinary command failures and HUP/INT/TERM, and retains the previous tree and launcher as private backups after success. The directory replacement uses two renames, so it is not a zero-gap exchange or a power-loss transaction; keep the printed backup paths for recovery after an uncatchable interruption. No existing customizations are silently deleted.

Ghostty config is available at `$(brew --prefix)/share/trmnl/ghostty/config` — copy it to `~/.config/ghostty/config` if you use Ghostty.

See `CONFIG_GUIDE_COMPLETE.md` for detailed setup of each tool.

## Requirements

- macOS or Linux (Windows via WSL)
- Homebrew
- A Nerd Font: `brew install --cask font-jetbrains-mono-nerd-font`
- Recommended terminal: [Ghostty](https://ghostty.org) (`brew install --cask ghostty`)
- Optional: `ANTHROPIC_API_KEY` for AI features

## Source validation

`bash test_suite.sh` checks source structure, syntax and literal leader mappings in a private temporary HOME. It requires executable Neovim, Zsh, Ruby and Python 3 for those checks. Neovim uses `-u NONE -i NONE --noplugin` and `loadfile`; configuration is compiled without executing plugin bootstrap. Missing validators and nonzero validator exits fail. The static mapping checker ignores Lua comments and distinguishes modes; dynamic, conditional and plugin-generated mappings need independent editor validation.

JavaScript debugging expects Mason's `js-debug-adapter` directory containing `js-debug/src/dapDebugServer.js`, launched with Node. Install and verify a compatible adapter separately. The generic Linux/WSL Yazi opener uses `xdg-open` from `xdg-utils`; WSL requires a functioning desktop/system opener. Source validation does not establish plugin execution, DAP breakpoints, native builds, package-manager behavior or Linux/WSL/macOS functional acceptance. The vendored autolock WASM and moving Lazy/Mason inputs also require independent provenance/runtime checks.

## Credits

trmnl curates and configures open source tools — it does not reimplement them.
Full credit goes to the authors and maintainers of every project it bundles or
depends on. The Neovim configuration is derived from
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) by TJ DeVries, and
the look is based on [Tokyo Night](https://github.com/folke/tokyonight.nvim).

See **[CREDITS.md](CREDITS.md)** for the complete list of every project, its
upstream, and its license.

## License

The MIT license in [`LICENSE`](LICENSE) covers trmnl's own scripts,
configuration, and glue code. Every bundled or depended-on project is governed by
its own license; see [CREDITS.md](CREDITS.md). Vendored components retain their
original license and copyright notices in place (e.g. `config/nvim/LICENSE.md`).
