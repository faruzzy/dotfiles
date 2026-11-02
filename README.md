# Faruzzy's Dotfiles

These are my personal dotfiles for macOS. They configure my development environment to my liking, with a focus on efficiency and a pleasant aesthetic.

![image](https://user-images.githubusercontent.com/766723/227434030-02bc9326-b9b3-4dc0-8201-f27a1e92856a.png)

## Philosophy

The guiding principle that I follow when configuring my dotfiles is that things should be easy to do. So easy in fact that it should favor laziness. Everything here revolves around `vim` and its movement.

## What's Inside?

This repository contains configurations for a variety of tools, including:

*   **Terminal:** Alacritty, Ghostty, tmux
*   **Shell:** Zsh, Antidote plugins, Starship prompt, Atuin history, mise runtimes
*   **Editor:** Neovim
*   **Git:** git, git-delta, tig
*   **Window Management:** AeroSpace, AltTab
*   **Other Tools:** fzf, bat, ripgrep, and many more.

## Installation

The `install.sh` script automates the setup process. It is idempotent and Bash 3.2 compatible (works on a fresh macOS). It will:

1.  Install Xcode Command Line Tools.
2.  Install Homebrew, then everything in the `Brewfile` (CLI tools, Neovim, GUI apps, fonts, and Temurin JDKs, with Rosetta for the x86-only ones).
3.  Install Monaco Nerd Font Mono, which has no Homebrew cask.
4.  Install global Node (LTS) and Java through [mise](https://mise.jdx.dev/), plus global npm packages.
5.  Install Codex CLI.
6.  Install tmux plugins and set up [everything.fzf](https://github.com/junegunn/everything.fzf).
7.  Install VS Code extensions.
8.  Create symbolic links for the dotfiles in this repository.
9.  Optionally set up a work Git identity for repos under `~/github/work`.
10. Start or reload AeroSpace after its config is linked.
11. Set up Antidote and Atuin.
12. Apply macOS system preferences.

When it finishes, it lists any warnings and exits nonzero if there were some.

To start the installation, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/faruzzy/dotfiles/master/install.sh)"
```

## Neovim Configuration

My Neovim setup is tailored for a modern development workflow, with a focus on providing a rich and efficient coding experience. It is built in Lua and managed by [lazy.nvim](https://github.com/folke/lazy.nvim), with plugin specs split across focused files.

### Structure

```
nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── faruzzy/                # Core settings, keymaps, autocommands
│   ├── lsp/                    # LSP server definitions and attach hooks
│   ├── plugins/                # Plugin specs
│   ├── config/                 # Theme, statusline and fzf-lua helpers
│   └── utils.lua               # Helper functions
├── snippets/                   # Custom JS/TS/React/Rust snippets
├── after/ftplugin/             # React filetype tweaks
└── after/queries/              # Treesitter query overrides
```

### Theme

[Catppuccin](https://github.com/catppuccin/nvim) (mocha) with custom highlight overrides, rounded floating window borders, and full Nerd Font support.

### LSP

Servers are installed with [mason.nvim](https://github.com/williamboman/mason.nvim) and enabled through Neovim's native `vim.lsp` API. Shared attach behavior lives in `nvim/lua/lsp/on_attach.lua`, while per-server configuration lives in `nvim/lua/lsp/servers/`.

| Server | Language |
|--------|----------|
| lua_ls | Lua |
| pyright | Python |
| rust_analyzer | Rust (with rustaceanvim) |
| tsgo | TypeScript / JavaScript (with tsgo.nvim) |
| eslint | JS/TS linting |
| emmet_language_server | HTML/CSS abbreviations |
| tailwindcss | Tailwind CSS |
| html / cssls | HTML / CSS |
| jsonls | JSON (with schemastore schemas) |
| yamlls | YAML |
| gopls | Go |
| clangd | C/C++ |
| vimls | Vim script |

`tsgo` (the native TypeScript Go port) is set up by [tsgo.nvim](https://github.com/faruzzy/tsgo.nvim) rather than Mason or `nvim/lua/lsp/servers/`; a local checkout at `~/github/tsgo.nvim` takes precedence over GitHub. `rust_analyzer` is installed by Mason but managed by `rustaceanvim`.

### Completion

Powered by [blink.cmp](https://github.com/Saghen/blink.cmp), a Rust-based completion engine. Sources include LSP, snippets (LuaSnip), path, buffer, and lazydev. The setup includes command-line completion, documentation popups, custom kind icons, and per-language completion detail for LSP items.

### Formatting

[conform.nvim](https://github.com/stevearc/conform.nvim) handles format-on-save with per-language formatters:

*   **JS/TS/HTML/CSS/JSON/YAML:** prettierd/prettier
*   **Lua:** stylua
*   **Python:** isort + black
*   **Go:** goimports + gofmt
*   **Rust:** rust-analyzer fallback
*   **Shell:** shfmt
*   **Zig:** zigfmt

### Fuzzy Finding

[fzf-lua](https://github.com/ibhagwan/fzf-lua) is used for fuzzy finding, LSP navigation, diagnostics, Git pickers, command history, keymaps, marks, registers, and TODO search:

| Binding | Action |
|---------|--------|
| `<C-p>` | Find files |
| `<M-f>` | Grep project |
| `<leader><CR>` | Open buffers |
| `<leader>/` | Buffer lines |
| `<leader>fw` | Grep word under cursor |
| `gd` / `gr` / `gi` | Smart definition / references / implementation |

### Git

*   [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) -- inline hunk indicators, stage/reset (`<leader>hs`/`<leader>hr`), blame (`<leader>hb`)
*   [vim-fugitive](https://github.com/tpope/vim-fugitive) -- full Git command suite (`g<CR>` for status, `<leader>gd` for diff)
*   [diffview.nvim](https://github.com/sindrets/diffview.nvim) -- visual diff browser

### Language-Specific Tooling

**TypeScript / JavaScript**
*   [tsgo.nvim](https://github.com/faruzzy/tsgo.nvim) with native `vim.lsp`, inlay hints, source definition (`gD`), and import management (`<leader>io` organize, `<leader>ia` add missing, `<leader>ir` remove unused, `<leader>if` fix all, `<leader>ii` all three at once)
*   Custom React hook snippets (`us` useState, `ue` useEffect, `ur` useRef, `um` useMemo, `uc` useCallback, and more)
*   Programmatic React component snippet with auto prop destructuring
*   JSDoc-friendly comment continuation and React filetype tweaks in `after/ftplugin`

**Rust**
*   [rustaceanvim](https://github.com/mrcjkb/rustaceanvim) with hover actions, runnables (`gBr`), debuggables (`gBR`), macro expansion (`gBe`), and external docs (`gK`)
*   Custom Rust snippets (structs, enums, traits, impls, tests, error handling, and more)

### Key Bindings

Leader key is `,` (comma). A few highlights:

**General**

| Binding | Action |
|---------|--------|
| `<Tab>` | Switch to last buffer |
| `<C-c>` | Toggle file explorer (neo-tree) |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>e` | Diagnostic float |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>ti` | Toggle inlay hints |
| `<leader>tc` | Toggle conceal |
| `<leader>ut` | Undo tree |
| `<leader>ta` | Toggle auto-save |
| `<leader>1`-`5` | Jump to buffer 1-5 |
| `<A-j>` / `<A-k>` | Move line(s) up / down |
| `<leader>.` | Compile and run (C, Go, Java, JS, TS, Lua, Python, sh) |
| `<CR>` | Re-run last ex command |
| `gR` | Find references to enclosing function |

**Buffers & Windows**

| Binding | Action |
|---------|--------|
| `]b` / `[b` | Next / previous buffer |
| `<leader>aq` | Close all other buffers |
| `<leader>o` | Close all other windows |
| `<leader>x` | Save and close buffer |
| `<leader>X` | Save all and quit |

**Fuzzy Finding (fzf-lua)**

| Binding | Action |
|---------|--------|
| `<C-p>` | Find files |
| `<M-f>` | Grep project |
| `<leader><CR>` | Open buffers |
| `<leader>/` | Search current buffer lines |
| `<leader>fw` / `<leader>fW` | Grep word under cursor (project / buffer) |
| `<C-g>` | Resume last fzf picker |
| `<leader>of` | Recently opened files |
| `gd` / `gr` / `gi` | Go to definition / references / implementation |
| `D` | Go to type definition |
| `<leader>ds` / `<leader>ws` | Document / workspace symbols |
| `<leader>dw` | Workspace diagnostics |
| `<leader>k` | Keymaps |
| `<leader>m` | Marks |
| `<leader>"` | Registers |
| `<leader>sh` | Help tags |

**Git (fzf-lua + gitsigns + fugitive)**

| Binding | Action |
|---------|--------|
| `<leader>gx` / `<leader>gX` | Buffer commits / Git commits |
| `<leader>gS` | Git status |
| `<leader>gB` | Git branches |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk |
| `<leader>hS` / `<leader>hR` | Stage / reset entire buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>tg` | Preview hunk inline |
| `<leader>tw` | Toggle word diff |
| `]c` / `[c` | Next / previous hunk |
| `]C` / `[C` | Next / previous staged hunk |
| `<leader>pr` | Open GitHub PR for current branch |

**TODOs**

| Binding | Action |
|---------|--------|
| `]t` / `[t` | Next / previous TODO comment |
| `<leader>td` | TODO list in Trouble |
| `<leader>tb` | Buffer TODOs in Trouble |
| `<leader>st` | Search TODOs with fzf-lua |

**Clipboard**

| Binding | Action |
|---------|--------|
| `<leader>yfn` | Copy filename |
| `<leader>yp` / `<leader>yap` | Copy relative / absolute path |
| `<leader>yfp` / `<leader>yafp` | Copy relative / absolute filepath |

**Search**

| Binding | Action |
|---------|--------|
| `<leader>?` | Google search word under cursor |
| `<leader>!` | Google "I'm Feeling Lucky" |

Use [which-key.nvim](https://github.com/folke/which-key.nvim) to discover all available bindings -- just press `<leader>` and wait.

### UI

*   [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) -- tabline with buffer grouping by language and type
*   [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) -- statusline showing mode, git branch, diagnostics, LSP status, and tmux zoom indicator
*   [incline.nvim](https://github.com/b0o/incline.nvim) -- floating filename labels on splits
*   [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) -- indent guides
*   [trouble.nvim](https://github.com/folke/trouble.nvim) -- diagnostics panel (`<leader>tt`)

### Notable Extras

*   **Native `vim.lsp` configuration** -- no `nvim-lspconfig`; servers are configured with `vim.lsp.config()` / `vim.lsp.enable()`
*   **mise runtime management** -- reads project runtime files through the shell integration and installs global Node/Java during setup
*   **Atuin history** -- local-only shell history with fuzzy search
*   **Antidote shell plugins** -- static Zsh plugin bundle generated from `.zsh_plugins.txt`
*   **Code action lightbulb** -- shows a hint when code actions are available
*   **Treesitter** -- 35+ parsers with text objects (`af`/`if` for functions, `ac`/`ic` for classes), auto-tag closing, and sticky context
*   **vim-tmux-navigator** -- seamless `<C-h/j/k/l>` navigation between Neovim splits and tmux panes
*   **[gx.nvim](https://github.com/chrishrb/gx.nvim)** -- smart URL opening under cursor
*   **[in-and-out.nvim](https://github.com/ysmb-wtsg/in-and-out.nvim)** -- jump out of surrounding delimiters
*   **[early-retirement.nvim](https://github.com/chrisgrieser/nvim-early-retirement)** -- auto-close inactive buffers
*   **[todo-comments.nvim](https://github.com/folke/todo-comments.nvim)** -- TODO/FIXME navigation and fzf/Trouble integration
*   **nvim-lsp-file-operations** -- LSP-aware file rename via neo-tree
*   **auto-save** -- saves on focus loss and buffer switch, and shortly after leaving insert mode or changing text; tsx/jsx are saved only after 2s idle in normal mode, so format-on-save never runs mid-edit
*   **Sessions** ([persistence.nvim](https://github.com/folke/persistence.nvim)) -- per directory and Git branch, restored automatically
*   **persistent undo** -- undo history survives across sessions
*   **`:JsConfig`** -- scaffolds a `jsconfig.json` at the nearest `package.json` root

## Shell Workflow

The shell setup is optimized for fast interactive use:

*   **Antidote** loads Zsh plugins from a generated static bundle.
*   **Starship** provides the prompt, with directory context tuned in `config/starship.toml`.
*   **mise** manages Node, Java, and other project runtimes.
*   **Atuin** provides local-only fuzzy shell history.
*   **fzf** powers shell completion and custom helpers. `<Tab>` keeps normal completion, while `<C-x><C-i>` invokes fzf completion when available.
*   `git diff` completion falls back to file completion when Git's completion has no candidate.

## Helper Scripts

`bin/` is on `PATH` (via `.zshenv`) for personal scripts.

fzf-based helpers (`claude.fzf`, `codex.fzf`, `pr.fzf`, `mise.fzf`, `chrome.fzf`, and more) come from [everything.fzf](https://github.com/junegunn/everything.fzf): `install.sh` clones it to `~/github/everything.fzf` and links every `*.fzf` script into `~/.local/bin`. Re-run `install.sh` to pick up new scripts.

## Other Configurations

This repository also includes configuration files for:

*   **Alacritty:** A fast, cross-platform, OpenGL terminal emulator.
*   **Ghostty:** A fast, native terminal emulator.
*   **tmux:** A terminal multiplexer.
*   **Zsh:** A powerful shell using Antidote for plugins, Atuin for history, fzf for completion, and Starship for the prompt.
*   **Starship:** A minimal, blazing-fast cross-shell prompt.
*   **bat:** A cat(1) clone with syntax highlighting and Git integration.
*   **AeroSpace:** An i3-like tiling window manager with one workspace per app, shared by a three-monitor home setup and a laptop + wide-monitor work setup.
*   **mise:** Language runtime manager for global and project-local tool versions.
*   **and more...**

## Credits

Shamelessly copied from [various](https://github.com/junegunn/dotfiles) [places](https://github.com/addyosmani/dotfiles).
