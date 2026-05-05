#!/usr/bin/env bash

[ -f ~/.fzf/shell/key-bindings.bash ] && source ~/.fzf/shell/key-bindings.bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Mise (Language runtime manager)
if command -v mise > /dev/null; then
    eval "$(mise activate bash)"
fi

[ -f ~/.config/up/up.sh ] && source ~/.config/up/up.sh

. "$HOME/.cargo/env"
eval "$(starship init bash)"
