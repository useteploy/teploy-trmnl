# Configuration Guide — trmnl Terminal IDE

## Claude API Integration (CodeCompanion)

CodeCompanion.nvim provides AI-powered code assistance directly in Neovim. To enable it:

### 1. Get Your API Key

1. Visit [console.anthropic.com](https://console.anthropic.com)
2. Sign in or create an account
3. Go to **API Keys** → **Create Key**
4. Copy your key

### 2. Set Environment Variable

Add this to your `~/.zshrc` (or `~/.bashrc` on Linux):

```bash
export ANTHROPIC_API_KEY="your-key-here"
```

Then reload:
```bash
source ~/.zshrc
```

### 3. Use CodeCompanion in Neovim

- `<leader>ai` — AI Instructions (visual selection or line)
- `<leader>ac` — Open AI Chat
- `<leader>at` — Toggle Chat Panel

## Debugging

### Python
```python
# Just press F5 in Neovim to start debugging
def hello():
    print("debug here")  # F5 to debug
```

### JavaScript/TypeScript
```javascript
// F5 to start debugging
function hello() {
  console.log("debug here");  // F5 to debug
}
```

### Keybinds
- `F5` — Start/Continue debug
- `F1` — Step Into
- `F2` — Step Over
- `F3` — Step Out
- `<leader>db` — Toggle Breakpoint
- `<leader>dB` — Set Conditional Breakpoint
- `F7` — Toggle Debug UI

## Testing

Run tests with Neotest:

- `<leader>tr` — Run all tests in file
- `<leader>tn` — Run nearest test
- `<leader>ts` — Show test summary
- `<leader>tl` — Run last test
- `<leader>tf` — Open test result summary to inspect failures

Supports: Python, JavaScript/TypeScript, Go, Rust

## Language Servers

Language-server attachment occurs when a matching file is opened. Mason installation requests are assembled during configuration initialization; tools may be installed before that language is opened. The configured plugin and tool versions require separate runtime validation.

Install additional servers manually:
```bash
:Mason
```

Then search for your language and install the LSP.

## Git Integration

- `<leader>gg` — Open Lazygit
- Git diff uses Delta with side-by-side view
- Inline git hunks via `<leader>h*` commands

See `trmnl keys` for full keybind list.

---

## Scroll Speed Optimization

### Ghostty Mouse Wheel
- Default: `scroll-multiplier = 1` (one line per tick)
- Fine: `scroll-multiplier = 0.5` (half-line per tick)
- Ultra-fine: `scroll-multiplier = 0.1` (very slow)

**Current setting:** `0.5` (recommended balance)

Edit `~/.config/ghostty/config` if you need to adjust further.

### Zellij Fine-Grained Scrolling
When mouse scrolling feels too fast:

```
Ctrl+s           # Enter scroll mode
j/k              # Scroll 1 line up/down
u/d              # Scroll half-page up/down
PageUp/PageDown  # Full page scroll
```

### Neovim Scroll Speed
Add to `init.lua` for smoother scrolling:

```lua
-- Smooth scrolling
vim.opt.scrolloff = 8      -- Keep 8 lines visible when scrolling
vim.opt.sidescrolloff = 8  -- Same for horizontal scrolling
```

### Best Practice
- **Mouse wheel:** Use for quick navigation (Ghostty handles this)
- **Fine control:** Use Zellij scroll mode (`Ctrl+s`) or Neovim's `j/k` in scroll mode
- **Large jumps:** Use `Ctrl+f`/`Ctrl+b` or Page Up/Down

