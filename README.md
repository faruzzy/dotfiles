# Faruzzy's Dotfiles

These are my personal dotfiles for macOS. They configure my development environment to my liking, with a focus on efficiency and a pleasant aesthetic.

![image](https://user-images.githubusercontent.com/766723/227434030-02bc9326-b9b3-4dc0-8201-f27a1e92856a.png)

## Philosophy

The guiding principle that I follow when configuring my dotfiles is that things should be easy to do. So easy in fact that it should favor laziness. Everything here revolves around `vim` and its movement.

## What's Inside?

This repository contains configurations for a variety of tools, including:

*   **Terminal:** Alacritty, tmux
*   **Shell:** Zsh (with Oh My Zsh)
*   **Editor:** Neovim
*   **Git:** git, git-delta, tig
*   **Other Tools:** fzf, bat, ripgrep, and many more.

## Installation

The `install.sh` script automates the setup process. It will:

1.  Install Xcode Command Line Tools.
2.  Install Homebrew and a wide range of packages.
3.  Install several GUI applications.
4.  Install programming languages like Python, Node.js, and Java.
5.  Set up Zsh with Oh My Zsh and plugins.
6.  Configure Neovim with a rich set of plugins.
7.  Create symbolic links for the dotfiles in this repository.

To start the installation, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/faruzzy/dotfiles/main/install.sh)"
```

## Neovim Configuration

My Neovim setup is tailored for a modern development workflow, with a focus on providing a rich and efficient coding experience. It is built entirely in Lua and managed by [lazy.nvim](https://github.com/folke/lazy.nvim) with ~91 plugins, all lazy-loaded for fast startup.

### Structure

```
nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── faruzzy/                # Core settings, keymaps, autocommands
│   ├── lsp/                    # LSP server definitions and attach hooks
│   ├── plugins/                # Plugin specs (~37 files)
│   ├── config/                 # Theme and statusline components
│   └── utils.lua               # Helper functions
├── snippets/                   # Custom JS/TS/React snippets
└── after/queries/              # Treesitter query overrides
```

### Theme

[Catppuccin](https://github.com/catppuccin/nvim) (mocha) with custom highlight overrides, rounded floating window borders, and full Nerd Font support.

### LSP

Servers are managed by [mason.nvim](https://github.com/williamboman/mason.nvim) and configured via `mason-lspconfig`. The following servers are set up out of the box:

| Server | Language |
|--------|----------|
| lua_ls | Lua |
| pyright | Python |
| rust_analyzer | Rust (via rustaceanvim) |
| typescript-tools | TypeScript / JavaScript |
| eslint | JS/TS linting |
| emmet_language_server | HTML/CSS abbreviations |
| tailwindcss | Tailwind CSS |
| html / cssls | HTML / CSS |
| jsonls | JSON (with schemas) |
| yamlls | YAML |
| clangd | C/C++ |
| vimls | Vim script |

### Completion

Powered by [blink.cmp](https://github.com/Saghen/blink.cmp), a Rust-based completion engine. Sources include LSP, snippets (LuaSnip), path, buffer, and lazydev. Completions are context-aware (e.g. buffer-only inside comments) and sorted by frecency.

### Formatting

[conform.nvim](https://github.com/stevearc/conform.nvim) handles format-on-save with per-language formatters:

*   **JS/TS/HTML/CSS/JSON:** prettierd
*   **Lua:** stylua
*   **Python:** isort + black
*   **Go:** goimports + gofmt
*   **Rust:** rust-analyzer (built-in)
*   **Shell:** shfmt

### Fuzzy Finding

[fzf-lua](https://github.com/ibhagwan/fzf-lua) is used for all fuzzy finding:

| Binding | Action |
|---------|--------|
| `<C-p>` | Find files |
| `<M-f>` | Live grep |
| `<leader><CR>` | Open buffers |
| `<leader>/` | Buffer lines |
| `<leader>fw` | Grep word under cursor |
| `gd` / `gr` / `gi` | Go to definition / references / implementation |

### Git

*   [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) -- inline hunk indicators, stage/reset (`<leader>hs`/`<leader>hr`), blame (`<leader>hb`)
*   [vim-fugitive](https://github.com/tpope/vim-fugitive) -- full Git command suite (`g<CR>` for status, `<leader>gd` for diff)
*   [diffview.nvim](https://github.com/sindrets/diffview.nvim) -- visual diff browser

### Language-Specific Tooling

**TypeScript / JavaScript**
*   [typescript-tools.nvim](https://github.com/pmizio/typescript-tools.nvim) with inlay hints, auto JSX closing, and import management (`<leader>io` organize, `<leader>ia` add missing, `<leader>ir` remove unused)
*   Custom React hook snippets (`us` useState, `ue` useEffect, `ur` useRef, `um` useMemo, `uc` useCallback, and more)

**Rust**
*   [rustaceanvim](https://github.com/mrcjkb/rustaceanvim) with hover actions, runnables (`gBr`), debuggables (`gBR`), macro expansion (`gBe`), and external docs (`gK`)

### Key Bindings

Leader key is `,` (comma). A few highlights:

| Binding | Action |
|---------|--------|
| `<Tab>` | Switch to last buffer |
| `<C-c>` | Toggle file explorer (neo-tree) |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>e` | Diagnostic float |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>ti` | Toggle inlay hints |
| `<leader>ut` | Undo tree |
| `<leader>bd` | Delete buffer (preserve layout) |
| `<leader>1`-`5` | Jump to buffer 1-5 |

Use [which-key.nvim](https://github.com/folke/which-key.nvim) to discover all available bindings -- just press `<leader>` and wait.

### UI

*   [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) -- tabline with buffer grouping by language and type
*   [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) -- statusline showing mode, git branch, diagnostics, and LSP status
*   [incline.nvim](https://github.com/b0o/incline.nvim) -- floating filename labels on splits
*   [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) -- indent guides
*   [alpha.nvim](https://github.com/goolord/alpha-nvim) -- startup dashboard
*   [trouble.nvim](https://github.com/folke/trouble.nvim) -- diagnostics panel (`<leader>tt`)

### Notable Extras

*   **NVM auto-detection** -- reads `.nvmrc` / `.node-version` to use the correct Node version inside Neovim
*   **Code action lightbulb** -- shows a hint when code actions are available
*   **Treesitter** -- 40+ parsers with text objects (`af`/`if` for functions, `ac`/`ic` for classes), auto-tag closing, and sticky context
*   **vim-tmux-navigator** -- seamless `<C-h/j/k/l>` navigation between Neovim splits and tmux panes
*   **auto-save** -- saves on insert leave
*   **persistent undo** -- undo history survives across sessions

## Other Configurations

This repository also includes configuration files for:

*   **Alacritty:** A fast, cross-platform, OpenGL terminal emulator.
*   **tmux:** A terminal multiplexer.
*   **Zsh:** A powerful shell with Oh My Zsh for plugin and theme management.
*   **bat:** A cat(1) clone with syntax highlighting and Git integration.
*   **and more...**

## Credits

Shamelessly copied from [various](https://github.com/junegunn/dotfiles) [places](https://github.com/addyosmani/dotfiles).