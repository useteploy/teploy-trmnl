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

All config is symlinked from the Homebrew install into `~/.config/`:

- `nvim/` — Neovim (Kickstart-based)
- `zellij/` — Multiplexer
- `yazi/` — File manager
- `starship.toml` — Prompt

Git config is added as an `[include]` in your existing `~/.gitconfig` — your user settings are preserved.

Ghostty config is available at `$(brew --prefix)/share/trmnl/ghostty/config` — copy it to `~/.config/ghostty/config` if you use Ghostty.

See `CONFIG_GUIDE_COMPLETE.md` for detailed setup of each tool.

## Requirements

- macOS or Linux (Windows via WSL)
- Homebrew
- A Nerd Font: `brew install --cask font-jetbrains-mono-nerd-font`
- Recommended terminal: [Ghostty](https://ghostty.org) (`brew install --cask ghostty`)
- Optional: `ANTHROPIC_API_KEY` for AI features

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
