[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Set up git completions
if [[ -f ~/.git-completion ]]; then
	. ~/.git-completion
fi

if [ -e ~/.config/plugged/fzf/shell/completion.bash ]; then
	source ~/.config/plugged/fzf/shell/completion.bash
fi

if [[ -f ~/z.sh ]]; then
	. ~/z.sh
fi

# ~/.extra can be used for settings you don't want to commit
for file in ~/.{bash_prompt,exports,aliases,functions,bash_options,extra}; do
	[ -r "$file" ] && source "$file"
done
unset file

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null
done

# git-prompt
if [ ! -e ~/.git-prompt.sh ]; then
  	curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
fi

if [ -e ~/.git-prompt.sh ]; then
	source ~/.git-prompt.sh
fi

# Add bash completion for git.
# See: https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion
[ -f  /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

[[ -s ~/.bashrc ]] && source ~/.bashrc

export MANPATH="/opt/local/share/man:$MANPATH"
# Finished adapting your MANPATH environment variable for use with MacPorts.

[[ -s ~/.cargo/evn ]] && source "$HOME/.cargo/env"
