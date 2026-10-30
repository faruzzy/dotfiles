# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles for macOS (Apple Silicon), managed via symlinks from this repo to `$HOME`. Not a software project — there are no builds, tests, or linters. Changes are validated by sourcing configs or restarting the relevant tool.

The same repo runs on two Macs, a personal one and a work one, with different usernames and monitor setups (see AeroSpace). Don't assume anything that only holds on one of them.

## Setup & Installation

```bash
./install.sh    # Idempotent — safe to re-run. Installs Homebrew packages, symlinks dotfiles, sets up runtimes.
```

The install script symlinks individual files to `$HOME` and config directories to `~/.config/`. Existing files are backed up with timestamps before overwriting.

## Workflow Requirements

- Update CLAUDE.md when a change adds a non-obvious constraint, gotcha or cross-machine assumption, or makes existing text here wrong. Don't document keymaps or features that are visible in the code.

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

- `.zsh_plugins.zsh` is generated — edit `.zsh_plugins.txt`, then restart the shell.
- Optional runtime env files (e.g. `~/.deno/env`) must be guarded with an existence check; Homebrew installs don't create them.
- Git completion uses zsh's built-in `_git` (wrapped by `_git_with_file_fallback`). Don't source upstream `git-completion.zsh`: it needs `git-completion.bash` alongside it.

### Scripts (`bin/`)

On `PATH` via `.zshenv`. Symlinks into other checkouts must be relative (e.g. `bin/claude.fzf` → `../../everything.fzf/claude.fzf`, which needs `everything.fzf` cloned next to this repo): the username differs between the two Macs.

### Neovim (`nvim/`)

Lua config using **lazy.nvim**. Entry point: `nvim/init.lua`; leader is comma.

- `lua/faruzzy/` — options, keymaps, autocommands
- `lua/plugins/` — one spec per file. Only top-level files are imported; a subfolder needs an `init.lua` or its specs are silently ignored.
- `lua/config/` — plugin logic kept out of specs (e.g. `config/fzf-lua/`, `config/lualine/`)
- `lua/lsp/` — server configs (`servers.lua`, `servers/*.lua`) and LSP helpers

Gotchas:
- **Lazy loading:** every spec needs a `keys`/`cmd`/`event`/`ft` trigger. Plugins that set up `FileType` autocmds (nvim-ts-autotag, endwise) must load on `BufReadPre`/`BufNewFile` or they miss the first buffer.
- **Startup-time side effects:** lazy evaluates every spec file at startup, but a module only runs when required. Anything that must run at startup goes in a spec's `init` (e.g. fzf-lua's buffer→window tracker).
- **Colorscheme:** Catppuccin loads eagerly (`lazy = false`). Lazy-loading it races lualine's `auto` theme at VimEnter and leaves the statusline grey.
- **No nvim-lspconfig:** servers use native `vim.lsp.config`, so whatever lspconfig would inject must live in `lua/lsp/servers/*.lua`. Example: `eslint.lua` sets `settings.workspaceFolder` in `before_init`, or every diagnostic request fails.
- **`root_markers` are priority-ordered, not nearest-wins:** use nested groups and keep project markers ahead of the global `~/.eslintrc` fallback.
- **ESLint:** its pull diagnostics aren't in `vim.lsp.diagnostic.get_namespace(client.id, true)`; match on diagnostic `source` instead. Its first request in a fresh buffer can exceed `request_sync`'s 1s default, so pass a longer timeout.
- **tsgo** is set up by tsgo.nvim (uses `~/github/tsgo.nvim` if checked out, else GitHub), not here.
- **Git revision buffers** (`fugitive://`, `diffview://`): the shared `LspAttach` in `plugins/lsp.lua` detaches servers there, since they can't resolve relative imports.
- **Sessions** (persistence.nvim) are per directory and git branch. Auto-restore loads only that exact branch's session (`load()` falls back to main's) and runs via `vim.schedule` after VimEnter; sourced inside VimEnter, the first restored buffer never gets its FileType.
- **Auto-save:** tsx/jsx are excluded from auto-save.nvim and saved by a separate 2s idle timer outside insert mode, so format-on-save never runs mid-edit.
- **Floats** inherit borders from `opt.winborder`; don't pass `border =` per call.
- **Diagnostics:** unused/deprecated hints are dimmed via `DiagnosticUnnecessary` instead of virtual text, so `DiagnosticUnderlineHint` has no underline style.

### Tmux (`.tmux.conf`)

Prefix is `C-x` (not default `C-b`). Plugins via tpm: catppuccin/tmux, tmux-resurrect + tmux-continuum, vim-tmux-navigator.

Popup bindings that run shell functions use `zsh -c "source ~/.functions.zsh; <fn>"`, never `zsh -ci`: background jobs started by `.zshrc` (e.g. Atuin's indexer) make fzf inside `$(...)` fail with `input/output error`.

### Git (`.gitconfig`, `.functions.zsh`)

- Pager is git-delta (Catppuccin theme in `catppuccin.gitconfig`). Its default auto paging prints short output straight to the terminal; fzf loops that show diffs (e.g. `fstash`) must force `--paging=always` or the next fzf frame covers it.
- `git fzf` is a thin alias for `gfzf` in `.functions.zsh`; edit the browser there.
- Stash helpers: `stash^{/text}` only searches the newest stash, so name lookups go through `git stash list` (`sfind`). `git stash create` has no `--include-untracked`; `checkpoint` stages into a temporary index instead.
- fzf-git (`fzf-git.sh`) is sourced from the repo path by `.functions.zsh`, not symlinked into `$HOME`.
- Work identity: repos under `~/github/work/` include `~/.gitconfig-work` via `includeIf`. That file is machine-local, written by `install.sh` on the work Mac; if it's missing, git silently ignores the include.

### AeroSpace (`config/aerospace/aerospace.toml`)

One workspace per app (`alt-<key>` to switch, `alt-shift-<key>` to move a window). Shared by two setups:
- **Home**: three `DELL U2715H` monitors, laptop lid closed. Refer to them by position (1 = left, 2 = center, 3 = right): macOS numbers the identical Dells differently on each Mac.
- **Work**: built-in display + one Philips wide monitor (`PHL 346B1C`).

- Workspaces that must land sensibly in both setups use a list in `[workspace-to-monitor-force-assignment]` (first connected match wins), e.g. `['built-in', 3]` or `['^PHL 346B1C$', 1]`.
- `alt-<key>` bindings are global, so they shadow the same Option shortcut in every app (e.g. `alt-s` is unavailable to fzf).
- Window-specific behavior that `on-window-detected` can't express (titles set after creation, layouts depending on which apps are open) lives in `sync-*.sh` scripts run on startup and focus change.
- Validate with `aerospace reload-config`. Inside `run` strings, avoid backslashes and quote monitor names containing spaces (e.g. `"move-node-to-monitor 'DELL U2715H [(]3[)]'"`), or the whole config fails to load.

## Key Conventions

- **Theme**: Catppuccin Mocha everywhere (terminal, neovim, tmux, git-delta, bat, starship)
- **Fonts**: Nerd Fonts (FiraCode, JetBrains Mono). Ghostty uses Monaco Nerd Font Mono, which has no Homebrew cask (Monaco is Apple's font): `install_monaco_nerd_font` in `install.sh` downloads a pinned, checksum-verified thep0y release into `~/Library/Fonts`
- **Commit style**: Conventional commits (`feat:`, `fix:`, `perf:`, `chore:`, `refactor:`). Never include `Co-Authored-By` trailers. With succinct details
- **Commit grouping**: Group related commits where it makes sense
- **Branch naming**: `feature/description`, `master` is the main branch
- **Philosophy**: Vim keybindings everywhere (shell, tmux, editor, IDE)
