#!/bin/bash
# trmnl installer — works on macOS, Linux, and WSL
# Usage: curl -fsSL https://raw.githubusercontent.com/useteploy/teploy-trmnl/main/install.sh | bash
set -e

TRMNL_REPO="useteploy/teploy-trmnl"
TRMNL_BRANCH="main"
INSTALL_DIR="$HOME/.local/share/trmnl"
BIN_DIR="$HOME/.local/bin"

# ── Colors ──────────────────────────────────────────
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "  ${GREEN}>${NC} $1"; }
warn()  { echo -e "  ${YELLOW}!${NC} $1"; }
error() { echo -e "  ${RED}x${NC} $1"; exit 1; }

# ── Detect OS and package manager ───────────────────
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux)  OS="linux" ;;
        *)      error "Unsupported OS: $(uname -s)" ;;
    esac

    # Detect WSL
    if [ "$OS" = "linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then
        OS="wsl"
    fi

    # Detect package manager
    if command -v brew &>/dev/null; then
        PKG="brew"
    elif command -v apt-get &>/dev/null; then
        PKG="apt"
    elif command -v dnf &>/dev/null; then
        PKG="dnf"
    elif command -v pacman &>/dev/null; then
        PKG="pacman"
    elif command -v zypper &>/dev/null; then
        PKG="zypper"
    elif command -v apk &>/dev/null; then
        PKG="apk"
    else
        PKG="none"
    fi
}

# ── Install a package ───────────────────────────────
pkg_install() {
    local pkg="$1"
    local brew_name="${2:-$1}"

    if command -v "$pkg" &>/dev/null; then
        return 0
    fi

    case "$PKG" in
        brew)   brew install "$brew_name" ;;
        apt)    sudo apt-get install -y "$brew_name" ;;
        dnf)    sudo dnf install -y "$brew_name" ;;
        pacman) sudo pacman -S --noconfirm "$brew_name" ;;
        zypper) sudo zypper install -y "$brew_name" ;;
        apk)    sudo apk add "$brew_name" ;;
        *)      warn "Cannot install $pkg — no supported package manager found. Install it manually." ;;
    esac
}

# ── Install core dependencies ───────────────────────
install_deps() {
    echo ""
    echo -e "${BOLD}Installing dependencies...${NC}"
    echo ""

    # These are available in most system package managers
    # Portable to macOS's system Bash 3.2 (no associative arrays).
    local cmd package entry
    for entry in nvim:neovim fzf:fzf rg:ripgrep fd:fd-find bat:bat jq:jq git:git curl:curl; do
        cmd="${entry%%:*}"
        package="${entry#*:}"
        if [ "$cmd" = fd ] && { [ "$PKG" = brew ] || [ "$PKG" = pacman ]; }; then
            package=fd
        fi
        if command -v "$cmd" &>/dev/null; then
            info "$cmd already installed"
        else
            info "Installing $package..."
            pkg_install "$cmd" "$package" || warn "Failed to install $package — install manually"
        fi
    done

    # Tools that may need special install methods
    echo ""
    echo -e "${BOLD}Installing terminal tools...${NC}"
    echo ""

    # Zellij
    if ! command -v zellij &>/dev/null; then
        if [ "$PKG" = "brew" ]; then
            brew install zellij
        elif [ "$PKG" = "pacman" ]; then
            sudo pacman -S --noconfirm zellij
        else
            info "Installing zellij via official installer..."
            bash <(curl -fsSL https://zellij.dev/launch) 2>/dev/null || warn "Failed to install zellij — visit https://zellij.dev"
        fi
    else
        info "zellij already installed"
    fi

    # Yazi
    if ! command -v yazi &>/dev/null; then
        if [ "$PKG" = "brew" ]; then
            brew install yazi
        elif [ "$PKG" = "pacman" ]; then
            sudo pacman -S --noconfirm yazi
        else
            warn "Install yazi manually: https://yazi-rs.github.io/docs/installation"
        fi
    else
        info "yazi already installed"
    fi

    # Lazygit
    if ! command -v lazygit &>/dev/null; then
        if [ "$PKG" = "brew" ]; then
            brew install lazygit
        elif [ "$PKG" = "pacman" ]; then
            sudo pacman -S --noconfirm lazygit
        elif [ "$PKG" = "dnf" ]; then
            sudo dnf copr enable atim/lazygit -y && sudo dnf install -y lazygit
        else
            warn "Install lazygit manually: https://github.com/jesseduffield/lazygit#installation"
        fi
    else
        info "lazygit already installed"
    fi

    # Starship
    if ! command -v starship &>/dev/null; then
        if [ "$PKG" = "brew" ]; then
            brew install starship
        else
            info "Installing starship via official installer..."
            curl -fsSL https://starship.rs/install.sh | sh -s -- -y 2>/dev/null || warn "Failed to install starship"
        fi
    else
        info "starship already installed"
    fi

    # Zoxide
    if ! command -v zoxide &>/dev/null; then
        if [ "$PKG" = "brew" ]; then
            brew install zoxide
        else
            info "Installing zoxide via official installer..."
            curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh 2>/dev/null || warn "Failed to install zoxide"
        fi
    else
        info "zoxide already installed"
    fi

    # Eza
    if ! command -v eza &>/dev/null; then
        if [ "$PKG" = "brew" ]; then
            brew install eza
        elif [ "$PKG" = "pacman" ]; then
            sudo pacman -S --noconfirm eza
        elif [ "$PKG" = "apt" ]; then
            # eza needs the gierens PPA on Ubuntu
            warn "Install eza manually: https://eza.rocks"
        else
            warn "Install eza manually: https://eza.rocks"
        fi
    else
        info "eza already installed"
    fi

    # Delta
    if ! command -v delta &>/dev/null; then
        if [ "$PKG" = "brew" ]; then
            brew install git-delta
        elif [ "$PKG" = "pacman" ]; then
            sudo pacman -S --noconfirm git-delta
        else
            warn "Install delta manually: https://github.com/dandavison/delta#installation"
        fi
    else
        info "delta already installed"
    fi

    # Btop
    if ! command -v btop &>/dev/null; then
        pkg_install btop btop 2>/dev/null || warn "Install btop manually: https://github.com/aristocratos/btop"
    else
        info "btop already installed"
    fi

    # API + DB clients (atac = TUI API client, hurl = HTTP-as-code, lazysql = DB
    # browser). Reliably packaged only via Homebrew; elsewhere point at upstream
    # install docs. Graceful (warn, never fail) — consistent with the tools above.
    for entry in "atac|https://github.com/Julien-cpsn/ATAC#installation" \
                 "hurl|https://hurl.dev/docs/installation.html" \
                 "lazysql|https://github.com/jorgerojas26/lazysql#installation"; do
        cmd="${entry%%|*}"; link="${entry#*|}"
        if ! command -v "$cmd" &>/dev/null; then
            if [ "$PKG" = "brew" ]; then
                brew install "$cmd" 2>/dev/null || warn "Failed to install $cmd — see $link"
            else
                warn "Install $cmd manually: $link"
            fi
        else
            info "$cmd already installed"
        fi
    done
}

# ── Download and install trmnl configs ──────────────
install_configs() (
    # Stage on the installation filesystem; never remove the working tree first.
    set -e
    umask 077
    parent='' stage='' old_tree='' old_bin='' wrapper='' published=false bin_published=false
    parent="$(dirname "$INSTALL_DIR")"
    mkdir -p "$parent" "$BIN_DIR"
    [ ! -L "$INSTALL_DIR" ] || error "Refusing a symlink installation directory"
    [ ! -e "$INSTALL_DIR" ] || [ -d "$INSTALL_DIR" ] || error "Installation path is not a directory"
    stage="$(mktemp -d "$parent/.trmnl-stage.XXXXXXXX")"
    rollback_install() {
        local status=$?
        trap - EXIT HUP INT TERM
        if [ "$status" -ne 0 ]; then
            if [ "$bin_published" = true ]; then rm -f "$BIN_DIR/trmnl"; fi
            if [ -n "$old_bin" ] && { [ -e "$old_bin" ] || [ -L "$old_bin" ]; }; then
                mv "$old_bin" "$BIN_DIR/trmnl"
            fi
            if [ "$published" = true ]; then rm -rf "$INSTALL_DIR"; fi
            if [ -n "$old_tree" ] && [ -d "$old_tree/tree" ]; then
                mv "$old_tree/tree" "$INSTALL_DIR"
            fi
        fi
        [ -z "$wrapper" ] || rm -f "$wrapper"
        rm -rf "$stage"
        exit "$status"
    }
    trap rollback_install EXIT
    trap 'exit 129' HUP
    trap 'exit 130' INT
    trap 'exit 143' TERM
    command -v git >/dev/null || error "git is required to install trmnl"
    info "Downloading trmnl into staging..."
    git clone --depth 1 --branch "$TRMNL_BRANCH" "https://github.com/$TRMNL_REPO.git" "$stage/repo"
    mkdir "$stage/tree"
    cp -R "$stage/repo/config/." "$stage/tree/"
    cp "$stage/repo/bin/trmnl" "$stage/tree/trmnl-bin"
    for entry in nvim/init.lua zellij/config.kdl zellij/layouts/dev.kdl yazi/yazi.toml yazi/keymap.toml yazi/theme.toml ghostty/config starship.toml trmnl-gitconfig zshrc-block; do
        [ -s "$stage/tree/$entry" ] || error "Incomplete staged installation: $entry"
    done
    [ -s "$stage/tree/zellij/plugins/zellij-autolock.wasm" ] || error "Missing staged autolock plugin"
    [ "$(od -An -tx1 -N8 "$stage/tree/zellij/plugins/zellij-autolock.wasm" | tr -d ' \n')" = 0061736d01000000 ] || error "Invalid staged WASM header"
    bash -n "$stage/tree/trmnl-bin"
    bash -n "$stage/tree/zshrc-block"
    # Parse every Lua chunk with startup disabled; never execute configuration.
    [ -x "$(command -v nvim 2>/dev/null)" ] || error "Neovim is required to validate staged Lua"
    while IFS= read -r entry; do
        TRMNL_CHECK_FILE="$entry" nvim --headless -u NONE -i NONE --noplugin -n \
            -c 'lua local f,e=loadfile(os.getenv("TRMNL_CHECK_FILE")); if not f then print(e); vim.cmd("cquit 1") end' \
            -c 'qa!' || error "Invalid staged Lua: $entry"
    done < <(find "$stage/tree/nvim" -type f -name '*.lua')
    chmod +x "$stage/tree/trmnl-bin"
    wrapper="$(mktemp "$BIN_DIR/.trmnl-wrapper.XXXXXXXX")"
    cat > "$wrapper" << 'WRAPPER'
#!/bin/bash
export TRMNL_DIR="${TRMNL_DIR:-$HOME/.local/share/trmnl}"
exec "$TRMNL_DIR/trmnl-bin" "$@"
WRAPPER
    chmod 755 "$wrapper"
    if [ -e "$INSTALL_DIR" ]; then
        old_tree="$(mktemp -d "$parent/.trmnl-backup.XXXXXXXX")"
        mv "$INSTALL_DIR" "$old_tree/tree"
    fi
    published=true
    mv "$stage/tree" "$INSTALL_DIR"
    if [ -e "$BIN_DIR/trmnl" ] || [ -L "$BIN_DIR/trmnl" ]; then
        old_bin="$(mktemp "$BIN_DIR/.trmnl-bin-backup.XXXXXXXX")"
        rm "$old_bin"
        mv "$BIN_DIR/trmnl" "$old_bin"
    fi
    bin_published=true
    mv "$wrapper" "$BIN_DIR/trmnl"
    wrapper=''
    info "Binary installed to $BIN_DIR/trmnl"
    [ -z "$old_tree" ] || info "Previous tree preserved at $old_tree/tree"
    [ -z "$old_bin" ] || info "Previous launcher preserved at $old_bin"
    case ":$PATH:" in
        *":$BIN_DIR:"*) ;;
        *) warn "$BIN_DIR is not in PATH; trmnl setup adds a guarded shell entry" ;;
    esac
)

# ── Main ────────────────────────────────────────────
main() {
    echo ""
    echo -e "${BLUE}${BOLD}  ┌─────────────────────────────┐${NC}"
    echo -e "${BLUE}${BOLD}  │  trmnl installer            │${NC}"
    echo -e "${BLUE}${BOLD}  │  Terminal IDE               │${NC}"
    echo -e "${BLUE}${BOLD}  └─────────────────────────────┘${NC}"
    echo ""

    detect_os
    info "Detected: $OS ($PKG)"

    install_deps
    install_configs

    echo ""
    echo -e "${GREEN}${BOLD}  Installation complete!${NC}"
    echo ""
    echo -e "  Run: ${BOLD}trmnl setup${NC}    to link configs"
    echo -e "  Run: ${BOLD}trmnl doctor${NC}   to verify installation"
    echo -e "  Run: ${BOLD}trmnl${NC}          to launch"
    echo ""
    echo -e "  ${DIM}For Nerd Font icons, install JetBrains Mono Nerd Font${NC}"
    echo -e "  ${DIM}Recommended terminal: Ghostty (https://ghostty.org)${NC}"
    echo ""
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
