#!/usr/bin/env bash

[ -f ~/.fzf/shell/key-bindings.bash ] && source ~/.fzf/shell/key-bindings.bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

_lazy_load_nvm() {
    echo "🔄 Loading NVM..."
    unset -f nvm node npm npx yarn pnpm _lazy_load_nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

for cmd in nvm node npm npx yarn pnpm; do
    eval "${cmd}() { _lazy_load_nvm; ${cmd} \"\$@\"; }"
done

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.config/up/up.sh ] && source ~/.config/up/up.sh

. "$HOME/.cargo/env"
eval "$(starship init bash)"
