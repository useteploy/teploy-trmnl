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
    local -A tools=(
        [nvim]="neovim"
        [fzf]="fzf"
        [rg]="ripgrep"
        [fd]="fd-find"
        [bat]="bat"
        [jq]="jq"
        [git]="git"
        [curl]="curl"
    )

    # Adjust package names per manager
    if [ "$PKG" = "brew" ]; then
        tools[fd]="fd"
        tools[delta]="git-delta"
        tools[eza]="eza"
        tools[nvim]="neovim"
    elif [ "$PKG" = "apt" ]; then
        tools[fd]="fd-find"
        tools[bat]="bat"
    elif [ "$PKG" = "pacman" ]; then
        tools[fd]="fd"
        tools[bat]="bat"
        tools[delta]="git-delta"
    fi

    for cmd in "${!tools[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            info "$cmd already installed"
        else
            info "Installing ${tools[$cmd]}..."
            pkg_install "$cmd" "${tools[$cmd]}" 2>/dev/null || warn "Failed to install ${tools[$cmd]} — install manually"
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
}

# ── Download and install trmnl configs ──────────────
install_configs() {
    echo ""
    echo -e "${BOLD}Installing trmnl configs...${NC}"
    echo ""

    # Clean previous install
    if [ -d "$INSTALL_DIR" ]; then
        info "Removing previous trmnl installation..."
        rm -rf "$INSTALL_DIR"
    fi

    # Download repo
    info "Downloading trmnl..."
    mkdir -p "$INSTALL_DIR"
    if command -v git &>/dev/null; then
        git clone --depth 1 --branch "$TRMNL_BRANCH" "https://github.com/$TRMNL_REPO.git" "$INSTALL_DIR/repo" 2>/dev/null
        cp -r "$INSTALL_DIR/repo/config/"* "$INSTALL_DIR/"
        cp "$INSTALL_DIR/repo/bin/trmnl" "$INSTALL_DIR/trmnl-bin"
        rm -rf "$INSTALL_DIR/repo"
    else
        error "git is required to install trmnl"
    fi

    # Install binary
    mkdir -p "$BIN_DIR"
    cat > "$BIN_DIR/trmnl" << 'WRAPPER'
#!/bin/bash
# trmnl wrapper — redirects TRMNL_DIR for non-Homebrew installs
export TRMNL_DIR="$HOME/.local/share/trmnl"
WRAPPER

    # Append the actual script, replacing the brew --prefix line
    sed 's|TRMNL_DIR="$(brew --prefix)/share/trmnl"|TRMNL_DIR="$HOME/.local/share/trmnl"|' \
        "$INSTALL_DIR/trmnl-bin" | tail -n +2 >> "$BIN_DIR/trmnl"
    chmod +x "$BIN_DIR/trmnl"
    rm -f "$INSTALL_DIR/trmnl-bin"

    info "Binary installed to $BIN_DIR/trmnl"

    # Ensure ~/.local/bin is in PATH
    if ! echo "$PATH" | grep -q "$BIN_DIR"; then
        warn "$BIN_DIR is not in your PATH"
        warn "Add this to your ~/.zshrc or ~/.bashrc:"
        echo -e "    ${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    fi
}

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

main "$@"
