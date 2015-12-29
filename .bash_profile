[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Set up git completions
if [ -f ~/.git-completion ]; then
  . ~/.git-completion
fi

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra can be used for settings you don't want to commit
for file in ~/.{extra,bash_prompt,exports,aliases,functions,bash_options}; do
	[ -r "$file" ] && source "$file"
done
unset file

# init rvm
#source ~/.rvm/scripts/rvm

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
if [ "$OS" == 'osx' ]; then
	if [ -f `brew --prefix`/etc/bash_completion ]; then
		. `brew --prefix`/etc/bash_completion
	fi
elif [ "$OS" == 'ubuntu' ]; then
	# enable programmable completion features
	if ! shopt -oq posix; then
		if [ -f /usr/share/bash-completion/bash_completion ]; then
			. /usr/share/bash-completion/bash_completion
		elif [ -f /etc/bash_completion ]; then
			. /etc/bash_completion
		fi
	fi
fi




# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

[ -s "~/.dnx/dnvm/dnvm.sh" ] && . "~/.dnx/dnvm/dnvm.sh" # Load dnvm

#source kvm.sh

