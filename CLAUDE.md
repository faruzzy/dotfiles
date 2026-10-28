# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles for macOS (Apple Silicon), managed via symlinks from this repo to `$HOME`. Not a software project — there are no builds, tests, or linters. Changes are validated by sourcing configs or restarting the relevant tool.

## Setup & Installation

```bash
./install.sh    # Idempotent — safe to re-run. Installs Homebrew packages, symlinks dotfiles, sets up runtimes.
```

The install script symlinks individual files to `$HOME` and config directories to `~/.config/`. Existing files are backed up with timestamps before overwriting.

## Workflow Requirements
- Update CLAUDE.md before every git commit

## Validating Changes

- **Zsh config**: `zsh -i -c 'exit'` (check for errors/unexpected output), or `source ~/.zshrc` in a running shell
- **Tmux config**: `tmux source-file ~/.tmux.conf` or `prefix + r` (bound to reload)
- **Neovim**: `:checkhealth` after changes, or `nvim --headless "+q"` for startup errors
- **Shell startup time**: `ZSH_PROFILE=1 zsh -i -c 'zsh-profile'` (built-in profiling support)

## Architecture

### Shell Stack (Zsh)

`.zshrc` is the entry point. Load order matters:

1. `compinit` (completion system, cached for 24h)
2. **Antidote** plugin manager loads `.zsh_plugins.txt` -> generates static `.zsh_plugins.zsh`
3. OMZ lib (subset) + git plugin, zsh-autosuggestions, zsh-syntax-highlighting
4. **Starship** prompt (`config/starship.toml`, Catppuccin Mocha palette)
5. Sourced files: `.aliases`, `.functions.zsh`, `.extra` (gitignored, for secrets/local overrides)
6. **FZF** key bindings and completion
7. **Mise** (replaces nvm/jEnv — universal runtime manager)
8. **Atuin** (replaces built-in history search, Ctrl-R and up-arrow)

Optional runtime env files (e.g. `~/.deno/env`, `~/.bun/_bun`) are sourced only if they exist, since Homebrew installs don't create them.

Git completion uses zsh's built-in `_git` (wrapped by `_git_with_file_fallback` in `.zshrc`). Do not source upstream `git-completion.zsh` directly — it is a completion function that needs `git-completion.bash` alongside it.

`.zsh_plugins.zsh` is a generated file — edit `.zsh_plugins.txt` instead, then restart the shell to regenerate.

### Scripts (`bin/`)

On `PATH` via `.zshenv`. `bin/claude.fzf` is a relative symlink to `../../everything.fzf/claude.fzf`, so it needs `github.com/faruzzy/everything.fzf` cloned next to this repo (`~/github/everything.fzf`). Keep such links relative: the username differs between the personal and work Macs.

### Neovim (`nvim/`)

Lua-based config using **lazy.nvim** for plugin management. Entry point: `nvim/init.lua`.

- `lua/faruzzy/settings.lua` — vim options
- `lua/faruzzy/remap.lua` — keybindings (leader = comma)
- `lua/faruzzy/autocmd.lua` — autocommands (cursorline only in the focused window, except neo-tree, so the followed file stays highlighted; Go buffers pull in `mise bin-paths` when `go` is missing from a stale shell PATH, before gopls/conform start; class attribute values are shown by default in html/js/jsx/tsx and `<Leader>tc` hides them per buffer via `utils.apply_class_conceal`)
- `lua/plugins/` — ~45 lazy-loaded plugin specs. Every spec should have a `keys`/`cmd`/`event`/`ft` trigger; plugins that set up `FileType` autocmds (nvim-ts-autotag, endwise) load on `BufReadPre`/`BufNewFile` so they catch the first buffer. Only top-level files are imported (`setup('plugins')`); a subfolder needs an `init.lua` or its specs are silently ignored
- `lua/config/theme.lua` — Catppuccin Mocha theme with custom highlights
- `lua/plugins/catppuccin.lua` — colorscheme spec; loads eagerly (`lazy = false`) so lualine's `auto` theme sees Catppuccin's highlights instead of racing it at VimEnter
- `lua/lsp/` — per-language LSP server configurations (`servers.lua` keeps `proto` out of clangd's filetypes; clangd can't parse protobuf; the shared LspAttach in `plugins/lsp.lua` detaches servers and hides diagnostics on URI buffers like `fugitive://`)

Key subsystems: persistence.nvim (`lua/plugins/persistence.lua`; sessions saved per directory + git branch on exit, auto-restored by a plain `nvim` only when that exact branch has a session — `load()` would fall back to main's; loaded via `vim.schedule` after VimEnter so restored buffers get FileType/LSP; neo-tree closed before saving; `<Leader>qs/qS/ql/qd`), mason.nvim (LSP installer), blink.cmp (completion), copilot.vim (AI inline suggestions, lazy-loaded on InsertEnter / `:Copilot`), conform.nvim (formatting), tsgo.nvim (owns the tsgo TypeScript LSP setup — binary resolution incl. mise, root detection (bounded only by `.git`, so sub-packages with their own `package.json` still use a parent tsconfig; `allow_inferred_project` starts tsgo without any tsconfig/jsconfig, like VS Code, rooted at the repo or the file's directory), settings, import actions, object-property completion detection used by blink; uses `~/github/tsgo.nvim` if checked out, else GitHub), fzf-lua (fuzzy finding; also registered as `vim.ui.select`, so code actions open in fzf; `<C-p>`/`<Leader><CR>` focus an already-open file's window, but buffers removed with `:Bdelete` (unlisted) reopen in the current window; `gd` jumps straight to a single definition via `lsp.utils.jump_to_item`, which reuses the loaded buffer and clamps the line; `gR` (`lsp/enclosing_references.lua`) finds usages of the enclosing function/component (plain `const` variables are skipped; wrapped ones like `useCallback(() => …)` count), offering a nearest-first picker when declarations are nested), treesitter (syntax), auto-save.nvim (auto-save; tsx/jsx are excluded and instead saved by a separate 2s idle timer outside insert mode, so format-on-save never runs mid-edit), incline.nvim (floating filename label per split, bottom-right, hidden while the cursor is on the line it covers).

LSP servers are configured with native `vim.lsp.config` (no nvim-lspconfig), so anything lspconfig would normally inject must be provided in `lua/lsp/servers/*.lua`. For example, `eslint.lua` sets `settings.workspaceFolder` in `before_init` (without it every diagnostic request fails) and defines `:EslintFixAll` itself. `root_markers` lists are priority-ordered, not nearest-wins: use nested groups, and keep project-level markers ahead of the global `~/.eslintrc` fallback.

Diagnostics (`settings.lua`): unused/deprecated code (LSP hints tagged `unnecessary`/`deprecated`) is dimmed via `DiagnosticUnnecessary` instead of shown as virtual text (higher severities, e.g. `noUnusedLocals` errors, keep their message); underlines include HINT for that reason, and `DiagnosticUnderlineHint` has no underline style (`catppuccin_highlights.lua`).

Float borders come from `opt.winborder` (`MY_CONFIG.border_style`, `settings.lua`); hover, signature help, diagnostic floats and blink.cmp windows inherit it, so don't pass `border =` per call.

### Tmux (`.tmux.conf`)

Prefix is `C-x` (not default `C-b`). Vi-mode copy with pbcopy integration. Plugins via tpm:
- catppuccin/tmux (theme)
- tmux-resurrect + tmux-continuum (session persistence)
- vim-tmux-navigator (seamless vim/tmux pane navigation)

The fzf popup bindings (`M-t` words, ``M-` `` files, `prefix 0` panes) run `zsh -c "source ~/.functions.zsh; <fn>"`. Don't use `zsh -ci`: background jobs started by `.zshrc` (e.g. Atuin's search indexer) make fzf inside `$(...)` fail with `input/output error`.

### Git (`.gitconfig`)

Uses git-delta as pager with Catppuccin theme (`catppuccin.gitconfig`). Extensive aliases defined in `.gitconfig`. `git fzf` is a thin alias that sources `.functions.zsh` and runs `gfzf`; edit the commit browser there, not in `.gitconfig`.

fzf-git (`fzf-git.sh`, `Ctrl-G` + key pickers like `^G^B` branches, `^G^H` hashes) is sourced from the repo path by `.functions.zsh`; it is not symlinked into `$HOME`.

The default identity is the personal email. Repos under `~/github/work/` pick up the work email through `includeIf "gitdir:~/github/work/"` → `~/.gitconfig-work`. That file is machine-local (not in this repo) and is written by `setup_git_work_identity` in `install.sh` when you answer "yes" to "Is this a work computer?". If the file is missing, git silently ignores the include.

### AeroSpace (`config/aerospace/aerospace.toml`)

Tiling window manager with one workspace per app (`alt-<key>` to switch, `alt-shift-<key>` to move a window). The config is shared by two setups:
- **Home**: three `DELL U2715H` monitors, referenced by position (1 = left, 2 = center, 3 = right) because macOS numbers the identical Dells differently on each Mac; built-in display unused.
- **Work**: built-in display + one Philips wide monitor (`PHL 346B1C`).

Outlook (`E`) and Microsoft Teams (`Q`) sit on the built-in display at work and the right monitor at home (`['built-in', 3]`). VS Code (`V`) sits on the Philips at work and the left monitor at home (`['^PHL 346B1C$', 1]`). Teams' main window (titled `<Section> | <name>`) goes to `Q`; call/meeting windows (titles without `|`) float over Ghostty in `T`, via an `on-window-detected` rule plus `sync-teams-call-window.sh` (run on focus change) for windows whose title is set after creation.

Workspace `O` (`alt-o` / `alt-period`) holds Obsidian and Apple Notes. At work only, `sync-notes-workspace.sh` (run on startup, focus change and window detection) tiles them half and half when both are open, or floats a lone one on the left half. It re-applies only when that open/closed state changes, so manual moves stick.

Workspaces that should land somewhere sensible in both places use a list in `[workspace-to-monitor-force-assignment]`, e.g. `['built-in', 1]` or `[3, 2]` (first connected match wins). Validate with `aerospace reload-config`. Inside `run` command strings, avoid backslashes and quote monitor names containing spaces (e.g. `"move-node-to-monitor 'DELL U2715H [(]3[)]'"`) or the whole config fails to load.

## Key Conventions

- **Theme**: Catppuccin Mocha everywhere (terminal, neovim, tmux, git-delta, bat, starship)
- **Fonts**: Nerd Fonts (FiraCode, JetBrains Mono)
- **Commit style**: Conventional commits (`feat:`, `fix:`, `perf:`, `chore:`, `refactor:`). Never include `Co-Authored-By` trailers. With succinct details
- **Commit grouping**: Group related commits where it makes sense
- **Branch naming**: `feature/description`, `master` is the main branch
- **Philosophy**: Vim keybindings everywhere (shell, tmux, editor, IDE)
