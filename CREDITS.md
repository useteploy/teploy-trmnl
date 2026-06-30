# Credits & Acknowledgments

trmnl is a curated, preconfigured terminal environment. It does not reimplement
the tools it ships — it bundles configuration for, and depends on, excellent open
source projects built by others. Full credit goes to their authors and
maintainers.

This file lists every project trmnl uses, with its upstream and license. Two
categories matter for licensing:

- **Dependency** — installed on your machine by Homebrew, your system package
  manager, or `lazy.nvim` at runtime. trmnl references these but does not
  redistribute their code.
- **Vendored** — shipped inside this repository. These carry redistribution
  obligations, which we honor by preserving their license and copyright notices.

Licenses below are the upstream-declared SPDX identifiers. Each project is
governed solely by its own license; the MIT license in this repo's `LICENSE`
covers only trmnl's own scripts, configuration, and glue code.

---

## Editor base

| Project | Role | License | Upstream |
|---|---|---|---|
| kickstart.nvim | Neovim config base (**vendored, derived**) | MIT | https://github.com/nvim-lua/kickstart.nvim |
| Neovim | Editor | Apache-2.0 (+ Vim license parts) | https://neovim.io |

The Neovim configuration under `config/nvim/` is derived from kickstart.nvim by
TJ DeVries. Its original MIT copyright notice is preserved in
`config/nvim/LICENSE.md`.

## Terminal tools (dependencies)

| Project | Role | License | Upstream |
|---|---|---|---|
| Zellij | Terminal multiplexer | MIT | https://github.com/zellij-org/zellij |
| Yazi | File manager | MIT | https://github.com/sxyazi/yazi |
| Lazygit | Git TUI | MIT | https://github.com/jesseduffield/lazygit |
| Starship | Shell prompt | ISC | https://github.com/starship/starship |
| Ghostty | Terminal emulator (recommended) | MIT | https://github.com/ghostty-org/ghostty |

## CLI tools (dependencies)

| Project | Role | License | Upstream |
|---|---|---|---|
| ripgrep | Search | Unlicense / MIT | https://github.com/BurntSushi/ripgrep |
| fd | Find | Apache-2.0 / MIT | https://github.com/sharkdp/fd |
| bat | cat with wings | Apache-2.0 / MIT | https://github.com/sharkdp/bat |
| eza | ls replacement | EUPL-1.2 | https://github.com/eza-community/eza |
| delta | Git pager / diff | MIT | https://github.com/dandavison/delta |
| fzf | Fuzzy finder | MIT | https://github.com/junegunn/fzf |
| zoxide | Smart cd | MIT | https://github.com/ajeetdsouza/zoxide |
| btop | Resource monitor | Apache-2.0 | https://github.com/aristocratos/btop |
| atuin | Shell history | MIT | https://github.com/atuinsh/atuin |
| direnv | Per-dir env | MIT | https://github.com/direnv/direnv |
| tldr pages | Simplified man pages | MIT (client) / CC-BY-4.0 (pages) | https://github.com/tldr-pages/tldr |
| jq | JSON processor | MIT-style (jq License) | https://github.com/jqlang/jq |
| gh | GitHub CLI | MIT | https://github.com/cli/cli |
| git-credential-manager | Git credential helper | MIT | https://github.com/git-ecosystem/git-credential-manager |
| atac | Terminal API client | MIT | https://github.com/Julien-cpsn/ATAC |
| hurl | HTTP testing as code | Apache-2.0 | https://github.com/Orange-OpenSource/hurl |
| lazysql | Terminal database browser | MIT | https://github.com/jorgerojas26/lazysql |

## Theme & fonts

| Project | Role | License | Upstream |
|---|---|---|---|
| tokyonight.nvim | Neovim/terminal theme | Apache-2.0 | https://github.com/folke/tokyonight.nvim |
| Tokyo Night (original) | Color palette | MIT | https://github.com/enkia/tokyo-night-vscode-theme |
| JetBrains Mono | Font | OFL-1.1 | https://github.com/JetBrains/JetBrainsMono |
| Nerd Fonts | Font patcher / glyphs | MIT (patcher) + per-font licenses | https://github.com/ryanoasis/nerd-fonts |

## Zellij plugin

| Project | Role | License | Upstream |
|---|---|---|---|
| zellij-autolock | Auto lock/unlock plugin (**vendored .wasm**) | MIT | https://github.com/fresh2dev/zellij-autolock |

`config/zellij/plugins/zellij-autolock.wasm` is a prebuilt binary redistributed
under its MIT license.

## Neovim plugins (dependencies, fetched by lazy.nvim)

| Project | License | Upstream |
|---|---|---|
| lazy.nvim | Apache-2.0 | https://github.com/folke/lazy.nvim |
| blink.cmp | MIT | https://github.com/Saghen/blink.cmp |
| LuaSnip | Apache-2.0 | https://github.com/L3MON4D3/LuaSnip |
| friendly-snippets | MIT | https://github.com/rafamadriz/friendly-snippets |
| nvim-lspconfig | Apache-2.0 | https://github.com/neovim/nvim-lspconfig |
| mason.nvim | Apache-2.0 | https://github.com/mason-org/mason.nvim |
| mason-lspconfig.nvim | Apache-2.0 | https://github.com/mason-org/mason-lspconfig.nvim |
| mason-tool-installer.nvim | MIT | https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim |
| conform.nvim | MIT | https://github.com/stevearc/conform.nvim |
| nvim-lint | GPL-3.0 | https://github.com/mfussenegger/nvim-lint |
| nvim-treesitter | Apache-2.0 | https://github.com/nvim-treesitter/nvim-treesitter |
| nvim-ts-autotag | MIT | https://github.com/windwp/nvim-ts-autotag |
| telescope.nvim | MIT | https://github.com/nvim-telescope/telescope.nvim |
| telescope-fzf-native.nvim | MIT | https://github.com/nvim-telescope/telescope-fzf-native.nvim |
| telescope-ui-select.nvim | MIT | https://github.com/nvim-telescope/telescope-ui-select.nvim |
| neo-tree.nvim | MIT | https://github.com/nvim-neo-tree/neo-tree.nvim |
| nui.nvim | MIT | https://github.com/MunifTanjim/nui.nvim |
| plenary.nvim | MIT | https://github.com/nvim-lua/plenary.nvim |
| nvim-web-devicons | MIT | https://github.com/nvim-tree/nvim-web-devicons |
| mini.nvim | MIT | https://github.com/nvim-mini/mini.nvim |
| which-key.nvim | Apache-2.0 | https://github.com/folke/which-key.nvim |
| gitsigns.nvim | MIT | https://github.com/lewis6991/gitsigns.nvim |
| todo-comments.nvim | Apache-2.0 | https://github.com/folke/todo-comments.nvim |
| trouble.nvim | Apache-2.0 | https://github.com/folke/trouble.nvim |
| flash.nvim | Apache-2.0 | https://github.com/folke/flash.nvim |
| fidget.nvim | MIT | https://github.com/j-hui/fidget.nvim |
| nvim-autopairs | MIT | https://github.com/windwp/nvim-autopairs |
| indent-blankline.nvim | MIT | https://github.com/lukas-reineke/indent-blankline.nvim |
| guess-indent.nvim | MIT | https://github.com/NMAC427/guess-indent.nvim |
| nvim-highlight-colors | MIT | https://github.com/brenoprata10/nvim-highlight-colors |
| neoscroll.nvim | MIT | https://github.com/karb94/neoscroll.nvim |
| bufferline.nvim | GPL-3.0 | https://github.com/akinsho/bufferline.nvim |
| bufdelete.nvim | GPL-3.0 | https://github.com/famiu/bufdelete.nvim |
| toggleterm.nvim | GPL-3.0 | https://github.com/akinsho/toggleterm.nvim |
| lazygit.nvim | MIT | https://github.com/kdheepak/lazygit.nvim |
| harpoon (harpoon2) | MIT | https://github.com/ThePrimeagen/harpoon |
| undotree | BSD-3-Clause | https://github.com/mbbill/undotree |
| codecompanion.nvim | Apache-2.0 | https://github.com/olimorris/codecompanion.nvim |
| neotest | MIT | https://github.com/nvim-neotest/neotest |
| nvim-nio | MIT | https://github.com/nvim-neotest/nvim-nio |
| neotest-go | MIT | https://github.com/nvim-neotest/neotest-go |
| neotest-jest | MIT | https://github.com/nvim-neotest/neotest-jest |
| neotest-python | MIT | https://github.com/nvim-neotest/neotest-python |
| neotest-rust | MIT | https://github.com/rouge8/neotest-rust |
| tokyonight.nvim | Apache-2.0 | https://github.com/folke/tokyonight.nvim |

---

If you maintain a project listed here and want attribution changed or removed,
open an issue and we'll address it promptly.
