#!/usr/bin/env zsh
# Profiling: run `zsh-profile` to see startup bottlenecks
[[ -n "$ZSH_PROFILE" ]] && zmodload zsh/zprof

# Initialize completion system (optimized) — must run before plugins that use compdef
autoload -Uz compinit
# Only regenerate .zcompdump if it's older than 24h or doesn't exist
if [[ -n ~/.zcompdump(#qN.mh-24) ]]; then
    compinit -C
else
    compinit
fi

# --- Antidote Plugin Manager ---
# Install antidote if not already present: brew install antidote
ANTIDOTE_DIR="/opt/homebrew/opt/antidote/share/antidote"
if [[ -d "$ANTIDOTE_DIR" ]]; then
    source "$ANTIDOTE_DIR/antidote.zsh"
    # Generate a static plugin file if it doesn't exist or is older than the plugins list
    if [[ ! -f ~/.zsh_plugins.zsh || ~/.zsh_plugins.txt -nt ~/.zsh_plugins.zsh ]]; then
        antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh
    fi
    source ~/.zsh_plugins.zsh
fi

# Override the default g alias to ensure proper completion
unalias g 2>/dev/null  # Remove any existing alias
unalias md 2>/dev/null  # Remove Oh-My-Zsh md alias to allow our function to work

# Lazy-load heavy completions instead of loading via OMZ plugins
# docker/kubectl completions are generated on first use and cached
if (( $+commands[docker] )); then
    _lazy_docker_completion() {
        unfunction _lazy_docker_completion
        source <(docker completion zsh)
    }
    compdef _lazy_docker_completion docker
fi

if (( $+commands[kubectl] )); then
    alias k=kubectl
    _lazy_kubectl_completion() {
        unfunction _lazy_kubectl_completion
        source <(kubectl completion zsh)
    }
    compdef _lazy_kubectl_completion kubectl
fi

# Starship prompt
eval "$(starship init zsh)"

# Zsh options (equivalent to your .bash_options)
setopt AUTO_CD              # Automatically cd into typed directory names
setopt GLOB_DOTS            # Include dotfiles in globbing
setopt EXTENDED_GLOB        # Extended globbing patterns
setopt HIST_IGNORE_DUPS     # Don't record duplicates in history
setopt HIST_IGNORE_ALL_DUPS # Remove older duplicate entries from history
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks from history
setopt HIST_VERIFY          # Show command with history expansion before running
setopt SHARE_HISTORY        # Share history between all sessions
setopt APPEND_HISTORY       # Append to history file rather than replace
setopt INC_APPEND_HISTORY   # Write to history file immediately, not when shell exits
setopt CORRECT              # Auto correct mistakes in commands
setopt CORRECT_ALL          # Auto correct mistakes in arguments

# Enable partial completion
setopt complete_in_word
setopt always_to_end

# Zsh-specific enhancements
zmodload zsh/complist
zstyle ':completion:*' menu select # Better completion menu
bindkey -M menuselect '^n' menu-complete
bindkey -M menuselect '^p' reverse-menu-complete
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Load configuration files
for file in ~/.{aliases,functions.zsh,extra}; do
  [[ -r "$file" ]] && source "$file"
done
unset file

# FZF integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.fzf/shell/key-bindings.zsh ] && source ~/.fzf/shell/key-bindings.zsh
[ -f ~/.fzf/shell/completion.zsh ] && source ~/.fzf/shell/completion.zsh

# Mise (Language runtime manager)
if command -v mise > /dev/null; then
    eval "$(mise activate zsh)"
fi

# UP navigation
[ -f ~/.config/up/up.sh ] && source ~/.config/up/up.sh

# Rust environment
[ -s ~/.cargo/env ] && source ~/.cargo/env

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Git completion and prompt (if not using oh-my-zsh)
if [[ ! -f ~/.oh-my-zsh/oh-my-zsh.sh ]]; then
    # Download git completion for zsh if not exists
    if [[ ! -f ~/.git-completion.zsh ]]; then
        curl -o ~/.git-completion.zsh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
    fi
    [[ -f ~/.git-completion.zsh ]] && source ~/.git-completion.zsh
fi

# Atuin (shell history)
if command -v atuin > /dev/null; then
    eval "$(atuin init zsh)"
fi

# Colorful completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Better kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

eval "$(zoxide init zsh)"
