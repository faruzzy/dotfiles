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

`.zsh_plugins.zsh` is a generated file — edit `.zsh_plugins.txt` instead, then restart the shell to regenerate.

### Neovim (`nvim/`)

Lua-based config using **lazy.nvim** for plugin management. Entry point: `nvim/init.lua`.

- `lua/faruzzy/settings.lua` — vim options
- `lua/faruzzy/remap.lua` — keybindings (leader = comma)
- `lua/faruzzy/autocmd.lua` — autocommands
- `lua/plugins/` — ~45 lazy-loaded plugin specs
- `lua/config/theme.lua` — Catppuccin Mocha theme with custom highlights
- `lua/lsp/` — per-language LSP server configurations

Key subsystems: mason.nvim (LSP installer), blink.cmp (completion), conform.nvim (formatting), fzf-lua (fuzzy finding), treesitter (syntax), auto-save.nvim (auto-save, disabled for tsx/jsx to avoid conform format churn).

### Tmux (`.tmux.conf`)

Prefix is `C-x` (not default `C-b`). Vi-mode copy with pbcopy integration. Plugins via tpm:
- catppuccin/tmux (theme)
- tmux-resurrect + tmux-continuum (session persistence)
- vim-tmux-navigator (seamless vim/tmux pane navigation)

### Git (`.gitconfig`)

Uses git-delta as pager with Catppuccin theme (`catppuccin.gitconfig`). Extensive aliases defined in `.gitconfig`.

## Key Conventions

- **Theme**: Catppuccin Mocha everywhere (terminal, neovim, tmux, git-delta, bat, starship)
- **Fonts**: Nerd Fonts (FiraCode, JetBrains Mono)
- **Commit style**: Conventional commits (`feat:`, `fix:`, `perf:`, `chore:`, `refactor:`). Never include `Co-Authored-By` trailers.
- **Commit grouping**: Group related commits where it makes sense
- **Branch naming**: `feature/description`, `master` is the main branch
- **Philosophy**: Vim keybindings everywhere (shell, tmux, editor, IDE)
