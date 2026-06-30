class Trmnl < Formula
  desc "Terminal IDE — preconfigured terminal development environment"
  homepage "https://github.com/useteploy/teploy-trmnl"
  head "https://github.com/useteploy/teploy-trmnl.git", branch: "main"
  version "0.1.2"

  depends_on "neovim"
  depends_on "zellij"
  depends_on "yazi"
  depends_on "lazygit"
  depends_on "fzf"
  depends_on "zoxide"
  depends_on "ripgrep"
  depends_on "fd"
  depends_on "bat"
  depends_on "eza"
  depends_on "git-delta"
  depends_on "starship"
  depends_on "btop"
  depends_on "tldr"
  depends_on "gh"
  depends_on "jq"
  # API + database clients — the dev-loop tools trmnl was missing (an in-terminal
  # Postman/Bruno and a DB browser). All three are in homebrew-core.
  depends_on "atac"      # TUI API client (Postman-style, git-friendly collections)
  depends_on "hurl"      # plain-text HTTP requests + assertions for CI / request-as-code
  depends_on "lazysql"   # TUI database client (browse/query Postgres, MySQL, SQLite)
  # git-credential-manager is a cask on macOS and a formula on linuxbrew —
  # Homebrew tap formulas can't depend on casks, and dual-paths get rejected.
  # Made it optional and instructed through caveats below.

  def install
    bin.install "bin/trmnl"

    # Install all config files to share/trmnl/
    (share/"trmnl").install "config/nvim"
    (share/"trmnl").install "config/zellij"
    (share/"trmnl").install "config/yazi"
    (share/"trmnl").install "config/ghostty"
    (share/"trmnl").install "config/starship.toml"
    (share/"trmnl").install "config/trmnl-gitconfig"
    (share/"trmnl").install "config/zshrc-block"
  end

  def caveats
    <<~EOS
      To complete setup, run:
        trmnl setup

      Then restart your terminal or run:
        source ~/.zshrc

      For a Nerd Font (needed for icons), install:
        brew install --cask font-jetbrains-mono-nerd-font

      Recommended terminal emulator:
        brew install --cask ghostty
      Ghostty config available at: #{share}/trmnl/ghostty/config

      Optional — git credential caching over HTTPS:
        brew install --cask git-credential-manager     # macOS
        brew install git-credential-manager            # Linux

      Useful commands:
        trmnl keys      — keybind cheat sheet
        trmnl doctor    — check installation
        trmnl uninstall — remove configs
    EOS
  end
end
