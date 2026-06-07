# trmnl — Terminal IDE

A preconfigured terminal development environment built on Neovim, Zellij, and modern CLI tools.

## Install

### macOS & Linux

```bash
brew tap useteploy/tap
brew install teploy-trmnl
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
brew install teploy-trmnl
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

## License

MIT
