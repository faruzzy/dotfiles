#!/usr/bin/env zsh

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
autoload -Uz compinit && compinit  # Enable completion system
zstyle ':completion:*' menu select # Better completion menu
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Load configuration files
for file in ~/.{zshenv,aliases,functions.zsh,extra}; do
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

# UP navigation
[ -f ~/.config/up/up.sh ] && source ~/.config/up/up.sh

# Rust environment
[ -s ~/.cargo/env ] && source ~/.cargo/env

# Java environment
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

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

# Starship prompt
eval "$(starship init zsh)"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    docker
    kubectl
    brew
)

# History search with arrow keys
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Colorful completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Better kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

eval "$(zoxide init zsh)"

# Zoxide integration (replaces the old z function)
# Override zoxide's z function to provide interactive behavior when called without arguments
function z() {
  if [[ $# -eq 0 ]]; then
    # No arguments - show interactive directory selection
    local result
    result=$(zoxide query -l | fzf --height 40% --reverse --inline-info +s --tac)
    if [[ -n "$result" ]]; then
      cd "$result"
    fi
  else
    # Arguments provided - use zoxide's normal behavior
    __zoxide_z "$@"
  fi
}
