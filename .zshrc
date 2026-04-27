#!/usr/bin/env zsh
# Profiling: run `zsh-profile` to see startup bottlenecks
[[ -n "$ZSH_PROFILE" ]] && zmodload zsh/zprof

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

# Skip compaudit security check (saves ~20ms per shell)
ZSH_DISABLE_COMPFIX=true

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-autocomplete
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

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

# Zsh-specific enhancements (compinit already called by oh-my-zsh)
zstyle ':completion:*' menu select # Better completion menu
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

# Lazy load NVM (same as bash version but for zsh)
nvm() {
    echo "🔄 Loading NVM (first run)..."
    unset -f nvm node npm npx
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
}

# Lazy load functions for Node commands
for cmd in node npm npx; do
    eval "${cmd}() { echo '🔄 Loading NVM for ${cmd}...'; unset -f nvm node npm npx; export NVM_DIR=\"\$HOME/.nvm\"; [ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"; [ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"; ${cmd} \"\$@\"; }"
done

# Ensure NVM's current node version bin is in PATH
export NVM_DIR="$HOME/.nvm"
# Find the currently active or default node version
if [ -f "$NVM_DIR/alias/default" ]; then
    NVM_DEFAULT_VERSION=$(cat "$NVM_DIR/alias/default")
elif [ -d "$NVM_DIR/versions/node" ]; then
    # Use the first (and likely only) installed version
    NVM_DEFAULT_VERSION=$(ls "$NVM_DIR/versions/node" | head -n 1)
fi

if [ -n "$NVM_DEFAULT_VERSION" ] && [ -d "$NVM_DIR/versions/node/$NVM_DEFAULT_VERSION/bin" ]; then
    export PATH="$NVM_DIR/versions/node/$NVM_DEFAULT_VERSION/bin:$PATH"
fi

# Auto-switch Node version when entering a directory with .nvmrc or .node-version
_auto_nvm_use() {
    local nvmrc_file
    if [[ -f .nvmrc ]]; then
        nvmrc_file=".nvmrc"
    elif [[ -f .node-version ]]; then
        nvmrc_file=".node-version"
    fi

    if [[ -n "$nvmrc_file" ]]; then
        local required_version
        required_version=$(<"$nvmrc_file")
        local current_version
        current_version=$(node -v 2>/dev/null)
        if [[ "$current_version" != "v${required_version#v}" ]]; then
            # Calling nvm will trigger lazy-load if not yet loaded
            nvm use "$required_version"
        fi
    fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd _auto_nvm_use

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

# History search with arrow keys
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Colorful completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Better kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

eval "$(zoxide init zsh)"

# jenv (Java version manager)
if command -v jenv > /dev/null; then
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
    export JAVA_HOME="$(jenv javahome 2>/dev/null)"
fi
