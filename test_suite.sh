#!/bin/bash
# trmnl v0.1.2 Test Suite
# Tests all configs, keybinds, syntax, and dependencies

set -e

PASS=0
FAIL=0
WARN=0

# Base directory — auto-detect from script location
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
# No user init, shada, plugin, or cache state is used by this source checker.
VALIDATION_HOME="$(mktemp -d "${TMPDIR:-/tmp}/trmnl-source-check.XXXXXXXX")"
export HOME="$VALIDATION_HOME"
export XDG_CONFIG_HOME="$HOME/config" XDG_DATA_HOME="$HOME/data" XDG_CACHE_HOME="$HOME/cache" XDG_STATE_HOME="$HOME/state"
trap 'rm -rf "$VALIDATION_HOME"' EXIT

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  trmnl v0.1.2 — Test Suite${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""

# ── Helper Functions ──────────────────────────────────────────────
test_pass() {
  echo -e "  ${GREEN}✓${NC} $1"
  PASS=$((PASS + 1))
}

test_fail() {
  echo -e "  ${RED}✗${NC} $1"
  FAIL=$((FAIL + 1))
}

test_warn() {
  echo -e "  ${YELLOW}!${NC} $1"
  WARN=$((WARN + 1))
}

# ── TEST 1: File Structure ────────────────────────────────────────
echo -e "${BLUE}TEST 1: File Structure${NC}"

files=(
  "Formula/trmnl.rb"
  "bin/trmnl"
  "config/nvim/init.lua"
  "config/zellij/config.kdl"
  "config/yazi/yazi.toml"
  "config/starship.toml"
  "config/trmnl-gitconfig"
  "config/zshrc-block"
  "config/ghostty/config"
  "README.md"
  "CONFIG_GUIDE_COMPLETE.md"
)

for file in "${files[@]}"; do
  if [ -f "$BASE_DIR/$file" ]; then
    test_pass "File exists: $file"
  else
    test_fail "Missing file: $file"
  fi
done

echo ""

# ── TEST 2: Neovim Config Syntax ──────────────────────────────────
echo -e "${BLUE}TEST 2: Neovim Configuration${NC}"

if [ ! -x "$(command -v nvim 2>/dev/null)" ]; then
  test_fail "Neovim executable unavailable; Lua syntax was not checked"
else
  while IFS= read -r filepath; do
    if TRMNL_CHECK_FILE="$filepath" nvim --headless -u NONE -i NONE --noplugin -n \
        -c 'lua local f,e=loadfile(os.getenv("TRMNL_CHECK_FILE")); if not f then print(e); vim.cmd("cquit 1") end' \
        -c 'qa!' ; then
      test_pass "Lua syntax valid: ${filepath#"$BASE_DIR/"}"
    else
      test_fail "Lua parse/editor process failed: ${filepath#"$BASE_DIR/"}"
    fi
  done < <(find "$BASE_DIR/config/nvim" -type f -name '*.lua')
fi

echo ""

# ── TEST 3: Zellij Config ─────────────────────────────────────────
echo -e "${BLUE}TEST 3: Zellij Configuration${NC}"

zellij_file="$BASE_DIR/config/zellij/config.kdl"
if [ -f "$zellij_file" ]; then
  if grep -q "keybinds\|themes\|plugins" "$zellij_file"; then
    test_pass "Zellij config structure valid"
  else
    test_fail "Zellij config missing key sections"
  fi

  if grep -q "bind \"Ctrl p\"" "$zellij_file"; then
    test_pass "Zellij keybinds defined"
  else
    test_fail "Zellij keybinds missing"
  fi
fi

echo ""

# ── TEST 4: Shell Config ──────────────────────────────────────────
echo -e "${BLUE}TEST 4: Shell Configuration${NC}"

zshrc_block="$BASE_DIR/config/zshrc-block"
if [ -f "$zshrc_block" ]; then
  if [ -x "$(command -v zsh 2>/dev/null)" ] && zsh -n "$zshrc_block"; then
    test_pass "Zsh syntax valid"
  else
    test_fail "Zsh executable unavailable or shell syntax check failed"
  fi
  for script in install.sh bin/trmnl test_suite.sh; do
    if bash -n "$BASE_DIR/$script"; then test_pass "Bash syntax: $script"; else test_fail "Bash syntax: $script"; fi
  done

  checks=(
    "starship"
    "zoxide"
    "alias"
  )

  for check in "${checks[@]}"; do
    if grep -q "$check" "$zshrc_block"; then
      test_pass "Shell config includes: $check"
    else
      test_fail "Shell config missing: $check"
    fi
  done

  # Verify dangerous aliases are NOT present
  if grep -q "alias find=" "$zshrc_block"; then
    test_fail "Dangerous alias: find is shadowed"
  else
    test_pass "No dangerous find alias"
  fi

  if grep -q "alias grep=" "$zshrc_block"; then
    test_fail "Dangerous alias: grep is shadowed"
  else
    test_pass "No dangerous grep alias"
  fi

  # Verify zellij guard uses correct env var
  if grep -q 'ZELLIJ' "$zshrc_block"; then
    test_pass "Zellij auto-launch uses correct guard"
  else
    test_fail "Zellij auto-launch guard missing"
  fi
fi

echo ""

# ── TEST 5: Homebrew Formula ──────────────────────────────────────
echo -e "${BLUE}TEST 5: Homebrew Formula${NC}"

formula_file="$BASE_DIR/Formula/trmnl.rb"
if [ -f "$formula_file" ]; then
  if [ -x "$(command -v ruby 2>/dev/null)" ] && ruby -c "$formula_file"; then
    test_pass "Formula Ruby syntax valid"
  else
    test_fail "Ruby executable unavailable or formula syntax invalid"
  fi

  deps=(
    'depends_on "neovim"'
    'depends_on "zellij"'
    'depends_on "yazi"'
    'depends_on "lazygit"'
  )

  for dep in "${deps[@]}"; do
    if grep -q "$dep" "$formula_file"; then
      test_pass "Formula includes: $dep"
    else
      test_fail "Formula missing: $dep"
    fi
  done

  # Verify no placeholder URLs remain
  if grep -q "yourusername" "$formula_file"; then
    test_fail "Formula still has placeholder 'yourusername'"
  else
    test_pass "Formula URLs are set"
  fi

  # Verify no code after class end
  last_end=$(grep -n "^end" "$formula_file" | tail -1 | cut -d: -f1)
  total_lines=$(wc -l < "$formula_file")
  if [ "$last_end" -eq "$total_lines" ] || [ $((total_lines - last_end)) -le 1 ]; then
    test_pass "No dead code after class end"
  else
    test_fail "Code found after class end statement"
  fi
fi

echo ""

# ── TEST 6: Tool Dependencies ─────────────────────────────────────
echo -e "${BLUE}TEST 6: Tool Dependencies${NC}"

tools=(
  "nvim:neovim"
  "zellij:zellij"
  "yazi:yazi"
  "lazygit:lazygit"
  "fzf:fzf"
  "rg:ripgrep"
  "fd:fd"
  "bat:bat"
  "eza:eza"
  "starship:starship"
  "gh:github-cli"
)

for tool in "${tools[@]}"; do
  IFS=':' read -r cmd name <<< "$tool"
  if [ -x "$(command -v "$cmd" 2>/dev/null)" ]; then
    test_pass "Tool installed: $name ($cmd)"
  else
    test_warn "Tool not installed: $name ($cmd) - will be installed by Formula"
  fi
done

echo ""

# ── TEST 7: Keybind Conflicts ─────────────────────────────────────
echo -e "${BLUE}TEST 7: Keybind Analysis${NC}"

if [ -x "$(command -v python3 2>/dev/null)" ] && python3 "$BASE_DIR/tests/check_keymaps.py" "$BASE_DIR/config/nvim"; then
  test_pass "No duplicate literal Neovim leader mappings in overlapping modes"
else
  test_fail "Keymap analysis failed or Python 3 executable unavailable"
fi

echo ""

# ── TEST 8: Configuration Completeness ────────────────────────────
echo -e "${BLUE}TEST 8: Configuration Completeness${NC}"

configs=(
  "config/nvim/init.lua:Neovim main config"
  "config/zellij/config.kdl:Zellij config"
  "config/yazi/yazi.toml:Yazi config"
  "config/starship.toml:Starship prompt"
  "config/trmnl-gitconfig:Git config"
  "config/ghostty/config:Ghostty config"
)

for config in "${configs[@]}"; do
  IFS=':' read -r file desc <<< "$config"
  if [ -f "$BASE_DIR/$file" ] && [ -s "$BASE_DIR/$file" ]; then
    size=$(wc -l < "$BASE_DIR/$file")
    test_pass "$desc ($size lines)"
  else
    test_fail "Missing or empty: $desc"
  fi
done

echo ""

# ── TEST 9: Git Configuration ────────────────────────────────────
echo -e "${BLUE}TEST 9: Git Configuration${NC}"

gitconfig="$BASE_DIR/config/trmnl-gitconfig"
if [ -f "$gitconfig" ]; then
  if grep -q "delta" "$gitconfig"; then
    test_pass "Delta integration configured"
  else
    test_fail "Delta not configured in gitconfig"
  fi

  # Should NOT contain [user] section — that's the user's own config
  if grep -q "\[user\]" "$gitconfig"; then
    test_fail "Git config should not set [user] section (let users keep their own)"
  else
    test_pass "Git config does not override [user]"
  fi

  # Theme consistency check
  if grep -q "tokyonight" "$gitconfig"; then
    test_pass "Delta uses Tokyo Night theme"
  else
    test_fail "Delta theme is not Tokyo Night"
  fi
fi

echo ""

# ── TEST 10: LSP Configuration ────────────────────────────────────
echo -e "${BLUE}TEST 10: LSP Configuration${NC}"

init_lua="$BASE_DIR/config/nvim/init.lua"
if [ -f "$init_lua" ]; then
  if grep -q "mason-lspconfig\|ensure_installed" "$init_lua"; then
    test_pass "LSP manager configured"
  else
    test_fail "LSP manager configuration missing"
  fi

  lsps=("ts_ls" "pyright" "rust_analyzer" "gopls")
  found=0
  for lsp in "${lsps[@]}"; do
    if grep -q "$lsp" "$init_lua"; then
      found=$((found + 1))
    fi
  done

  if [ $found -ge 2 ]; then
    test_pass "Multiple LSPs configured ($found found)"
  else
    test_warn "Fewer LSPs than expected"
  fi

  # Check stylua is NOT in servers table
  if grep -A1 "local servers" "$init_lua" | head -60 | grep -q "stylua = {}"; then
    test_fail "stylua is listed as an LSP server (it's a formatter)"
  else
    test_pass "stylua not in LSP servers table"
  fi
fi

echo ""

# ── TEST 11: Plugin Load Order ────────────────────────────────────
echo -e "${BLUE}TEST 11: Plugin Loading${NC}"

plugin_files=(
  "config/nvim/lua/custom/plugins/codecompanion.lua"
  "config/nvim/lua/custom/plugins/neotest.lua"
  "config/nvim/lua/custom/plugins/harpoon.lua"
)

for plugin in "${plugin_files[@]}"; do
  if [ -f "$BASE_DIR/$plugin" ]; then
    if grep -q "^return {" "$BASE_DIR/$plugin"; then
      test_pass "Plugin spec valid: $(basename $plugin)"
    else
      test_fail "Plugin spec missing return: $(basename $plugin)"
    fi
  fi
done

# Only repository string tokens count; prose/comments do not declare plugins.
if [ -x "$(command -v python3 2>/dev/null)" ] && python3 "$BASE_DIR/tests/check_keymaps.py" "$BASE_DIR/config/nvim" --plugin mini.nvim; then
  test_pass "One active literal mini.nvim declaration"
else
  test_fail "mini.nvim declaration analysis failed"
fi

echo ""

# ── TEST 12: Shell Functions ──────────────────────────────────────
echo -e "${BLUE}TEST 12: Shell Functions${NC}"

zshrc="$BASE_DIR/config/zshrc-block"
functions=(
  "py-venv"
  "node-setup"
  "go-setup"
  "rust-setup"
  "profile-py"
)

for func in "${functions[@]}"; do
  if grep -q "function $func" "$zshrc"; then
    test_pass "Shell function defined: $func"
  else
    test_fail "Shell function missing: $func"
  fi
done

echo ""

# ── SUMMARY ───────────────────────────────────────────────────────
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${GREEN}Passed:${NC} $PASS"
echo -e "  ${RED}Failed:${NC} $FAIL"
echo -e "  ${YELLOW}Warnings:${NC} $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✓ SOURCE CHECKS PASSED — plugin/platform runtime acceptance is separate${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}✗ SOME TESTS FAILED${NC}"
  echo ""
  exit 1
fi
