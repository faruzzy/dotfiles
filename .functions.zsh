# Easily extract all compressed file types
extract () {
   if [ -f "$1" ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf -- "$1"    ;;
           *.tar.gz)    tar xvzf -- "$1"    ;;
           *.bz2)       bunzip2 -- "$1"     ;;
           *.rar)       unrar x -- "$1"     ;;
           *.gz)        gunzip -- "$1"      ;;
           *.tar)       tar xvf -- "$1"     ;;
           *.tbz2)      tar xvjf -- "$1"    ;;
           *.tgz)       tar xvzf -- "$1"    ;;
           *.zip)       unzip -- "$1"       ;;
           *.Z)         uncompress -- "$1"  ;;
           *.7z)        7z x -- "$1"        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file"
   fi
}


# Define a word using collinsdictionary.com
function define() {
  curl -s "http://www.collinsdictionary.com/dictionary/english/$*" | sed -n '/class="def"/p' | awk '{gsub(/.*<span class="def">|<\/span>.*/,"");print}' | sed "s/<[^>]\+>//g";
}

# Set up directory marking commands.
# See: http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
# And: https://news.ycombinator.com/item?id=6229001
export MARKPATH=$HOME/.marks
function jump {
    cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}

function mark {
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}

function unmark {
    rm -i "$MARKPATH/$1"
}

function marks {
    \ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}

function _jump {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local marks=$(find $MARKPATH -type l | awk -F '/' '{print $NF}')
    COMPREPLY=($(compgen -W '${marks[@]}' -- "$cur"))
    return 0
}

function _completemarks {
	local curw=${COMP_WORDS[COMP_CWORD]}
	local wordlist=$(find $MARKPATH -type l -printf "%f\n")
	COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
	return 0
}

#complete -o default -o nospace -F _jump jump ## commented out because "complete command not found"

# Epoch time conversion
function epoch() {
  TESTREG="[\d{10}]"
  if [[ "$1" =~ $TESTREG ]]; then
    # is epoch
    date -d @$*
  else
    # is date
    if [ $# -gt 0 ]; then
      date +%s --date="$*"
    else
      date +%s
    fi
  fi
}

# fshow - git commit browser
# thanks to http://junegunn.kr/2015/03/browsing-git-commits-with-fzf/
function fshow() {
  git log --graph --color=always \
	  --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
	  --bind "ctrl-m:execute:
				(grep -o '[a-f0-9]\{7\}' | head -1 |
				xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
				{}
FZF-EOF"
}

# fd - cd to selected directory
function fd() {
  DIR=`find ${1:-*} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf-tmux` \
	&& cd "$DIR"
}

# fda - including hidden directories
function fda() {
  DIR=`find ${1:-.} -type d 2> /dev/null | fzf-tmux` && cd "$DIR"
}
#
# fco - checkout git branch/tag
function fco() {
  local tags branches target
  tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") |
    fzf-tmux -l40 -- --no-hscroll --ansi +m -d "\t" -n 2 -1 -q "$*") || return
  git checkout $(echo "$target" | awk '{print $2}')
}

# ftags - search ctags
function ftags() {
  local line
  [ -e tags ] &&
  line=$(
    awk 'BEGIN { FS="\t" } !/^!/ {print toupper($4)"\t"$1"\t"$2"\t"$3}' tags |
    cut -c1-$COLUMNS | fzf --nth=2 --tiebreak=begin
  ) && $EDITOR $(cut -f3 <<< "$line") -c "set nocst" \
                                      -c "silent tag $(cut -f2 <<< "$line")"
}

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
function fe() {
  local file
  file=$(fzf-tmux --query="$1" --select-1 --exit-0)
  [ -n "$file" ] && ${EDITOR:-vim} "$file"
}

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
function fo() {
  local out file key
  IFS=$'\n' read -d '' -r -a out < <(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)
  key=${out[0]}
  file=${out[1]}
  if [ -n "$file" ]; then
	if [ "$key" = ctrl-o ]; then
	  open "$file"
	else
	  ${EDITOR:-vim} "$file"
	fi
  fi
}


if [ -n "$TMUX_PANE" ]; then
function fzf_tmux_helper() {
	local sz=$1;  shift
	local cmd=$1; shift
	tmux split-window $sz \
	  "bash -c \"\$(tmux send-keys -t $TMUX_PANE \"\$(source ~/.fzf.bash; $cmd)\" $*)\""
}

# https://github.com/wellle/tmux-complete.vim
function fzf_tmux_words() {
	fzf_tmux_helper \
	  '-p 40' \
	  'tmuxwords.rb --all --scroll 500 --min 5 | fzf --multi | paste -sd" " -'
}

# ftpane - switch pane (@george-b)
function ftpane() {
	local panes current_window current_pane target target_window target_pane
	panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
	current_pane=$(tmux display-message -p '#I:#P')
	current_window=$(tmux display-message -p '#I')

	target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

	target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
	target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

	if [[ $current_window -eq $target_window ]]; then
	  tmux select-pane -t ${target_window}.${target_pane}
	else
	  tmux select-pane -t ${target_window}.${target_pane} &&
	  tmux select-window -t $target_window
	fi
}

# Bind CTRL-X-CTRL-T to tmuxwords.sh
#bindkey '"\C-x\C-t": "$(fzf_tmux_words)\e\C-e"'

elif [ -d ~/github/iTerm2-Color-Schemes/ ]; then
function ftheme() {
	local base
	base=~/github/iTerm2-Color-Schemes
	$base/tools/preview.rb "$(
	  ls {$base/schemes,~/.vim/plugged/seoul256.vim/iterm2}/*.itermcolors | fzf)"
}
fi

# Switch tmux-sessions
fs() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" | \
    fzf-tmux --query="$1" --select-1 --exit-0) &&
  tmux switch-client -t "$session"
}

source ~/z.sh

# fbr - checkout git branch
function fbr() {
  local branches branch
  branches=$(git branch) &&
  branch=$(echo "$branches" | fzf-tmux -d 15 +m) &&
  git checkout $(echo "$branch" | sed "s/.* //")
}

# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
function fstash() {
  local out q k sha
    while out=$(
      git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
      fzf --ansi --no-sort --query="$q" --print-query \
          --expect=ctrl-d,ctrl-b);
    do
      q=$(head -1 <<< "$out")
      k=$(head -2 <<< "$out" | tail -1)
      sha=$(tail -1 <<< "$out" | cut -d' ' -f1)
      [ -z "$sha" ] && continue
      if [ "$k" = 'ctrl-d' ]; then
        git diff $sha
      elif [ "$k" = 'ctrl-b' ]; then
        git stash branch "stash-$sha" $sha
        break;
      else
        git stash show -p $sha
      fi
    done
}

# fcs - get git commit sha
# example usage: git rebase -i `fcs`
function fcs() {
  local commits commit
  commits=$(git log --color=always --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e --ansi --reverse) &&
  echo -n $(echo "$commit" | sed "s/ .*//")
}

# GIT heart FZF
# -------------

function is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

function gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-tmux -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

function gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-tmux --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

function gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-tmux --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -200'
}

function gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph |
  fzf-tmux --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -200' |
  grep -o "[a-f0-9]\{7,\}"
}

function gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-tmux --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d' ' -f1
}

# A helper function to join multi-line output from fzf
function join-lines() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

function bind-git-helper() {
  local char
  for c in $@; do
    eval "fzf-g$c-widget() LBUFFER+=\$(g$c | join-lines)"
    eval "zle -N fzf-g$c-widget"
    eval "bindkey '^g^$c' fzf-g$c-widget"
  done
}

bind-git-helper f b t r h
unset -f bind-git-helper

# Simple calculator
function calc() {
	local result=""
	result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')"
	#                       └─ default (when `--mathlib` is used) is 20
	#
	if [[ "$result" == *.* ]]; then
			# improve the output for decimal numbers
			printf "$result" |
			sed -e 's/^\./0./'        `# add "0" for cases like ".5"` \
				-e 's/^-\./-0./'      `# add "0" for cases like "-.5"`\
				-e 's/0*$//;s/\.$//'   # remove trailing zeros
	else
			printf "$result"
	fi
	printf "\n"
}


# Extract archives - use: extract <file>
# Based on http://dotfiles.org/~pseup/.bashrc
function extract() {
  if [ -f "$1" ] ; then
    local filename=$(basename "$1")
    local foldername="${filename%%.*}"
    local fullpath=`perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1"`
    local didfolderexist=false
    if [ -d "$foldername" ]; then
      didfolderexist=true
      read -p "$foldername already exists, do you want to overwrite it? (y/n) " -n 1
      echo
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        return
      fi
    fi
    mkdir -p "$foldername" && cd "$foldername"
    case $1 in
      *.tar.bz2) tar xjf "$fullpath" ;;
      *.tar.gz) tar xzf "$fullpath" ;;
      *.tar.xz) tar Jxvf "$fullpath" ;;
      *.tar.Z) tar xzf "$fullpath" ;;
      *.tar) tar xf "$fullpath" ;;
      *.taz) tar xzf "$fullpath" ;;
      *.tb2) tar xjf "$fullpath" ;;
      *.tbz) tar xjf "$fullpath" ;;
      *.tbz2) tar xjf "$fullpath" ;;
      *.tgz) tar xzf "$fullpath" ;;
      *.txz) tar Jxvf "$fullpath" ;;
      *.zip) unzip "$fullpath" ;;
      *) echo "'$1' cannot be extracted via extract()" && cd .. && ! $didfolderexist && rm -r "$foldername" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# animated gifs from any video
# from alex sexton   gist.github.com/SlexAxton/4989674
function gifify() {
  if [[ -n "$1" ]]; then
    if [[ $2 == '--good' ]]; then
      ffmpeg -i $1 -r 10 -vcodec png out-static-%05d.png
      time convert -verbose +dither -layers Optimize -resize 900x900\> out-static*.png  GIF:- | gifsicle --colors 128 --delay=5 --loop --optimize=3 --multifile - > $1.gif
      rm out-static*.png
    else
      ffmpeg -i $1 -s 600x400 -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > $1.gif
    fi
  else
    echo "proper usage: gifify <input_movie.mov>. You DO need to include extension."
  fi
}

# turn that video into webm.
# brew reinstall ffmpeg --with-libvpx
function webmify() {
  ffmpeg -i $1 -vcodec libvpx -acodec libvorbis -isync -copyts -aq 80 -threads 3 -qmax 30 -y $2 $1.webm
}

function rule() {
    printf "%$(tput cols)s\n"|tr " " "-"
}

# Create a new directory and enter it
function md() {
	mkdir -p "$@" && cd "$@"
}

# find shorthand
function f() {
    find . -name "$1"
}

# search chrome browser History
function ch() {
	local cols sep
	cols=$(( COLUMNS / 3 ))
	sep='{{::}}'

	# Copy History DB to circumvent the lock
	# - See http://stackoverflow.com/questions/8936878 for the file path
	cp -f ~/Library/Application\ Support/Google/Chrome/Default/History /tmp/h

	sqlite3 -separator $sep /tmp/h \
	  "select substr(title, 1, $cols), url
	   from urls order by last_visit_time desc" |
	awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
	fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
}

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
	cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
	local port="${1:-8000}"
	open "http://localhost:${port}/"
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# Create a data URL from a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1")
	if [[ $mimeType == text/* ]]; then
			mimeType="${mimeType};charset=utf-8"
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Create a git.io short URL
function gitio() {
	if [ -z "${1}" -o -z "${2}" ]; then
		echo "Usage: \`gitio slug url\`"
		return 1
	fi
	curl -i http://git.io/ -F "url=${2}" -F "code=${1}"
}

# A better git clone
# clones a repository, cds into it, and opens it in my editor.
#
# Based on https://github.com/stephenplusplus/dots/blob/master/.bash_profile#L68 by @stephenplusplus
#
# Note: subl is already setup as a shortcut to Sublime. Replace with your own editor if different
#
# - arg 1 - url|username|repo remote endpoint, username on github, or name of
#           repository.
# - arg 2 - (optional) name of repo
#
# usage:
#   $ clone things
#     .. git clone git@github.com:addyosmani/things.git things
#     .. cd things
#     .. subl .
#
#   $ clone yeoman generator
#     .. git clone git@github.com:yeoman/generator.git generator
#     .. cd generator
#     .. subl .
#
#   $ clone git@github.com:addyosmani/dotfiles.git
#     .. git clone git@github.com:addyosmani/dotfiles.git dotfiles
#     .. cd dots
#     .. subl .

function clone {
	# customize username to your own
	local username="faruzzy"
	local url=$1;
	local repo=$2;

	if [[ ${url:0:4} == 'http' || ${url:0:3} == 'git' ]]
	then
		# just clone this thing.
		repo=$(echo $url | awk -F/ '{print $NF}' | sed -e 's/.git$//');
	elif [[ -z $repo ]]
	then
		# my own stuff.
		repo=$url;
		url="git@github.com:$username/$repo";
	else
		# not my own, but I know whose it is.
		url="git@github.com:$url/$repo.git";
	fi

	git clone $url $repo && cd $repo && subl .;
}

# open new cloned project with IntteliJ
function clonei {
	# customize username to your own
	local username="faruzzy"
	local url=$1;
	local repo=$2;

	if [[ ${url:0:4} == 'http' || ${url:0:3} == 'git' ]]
	then
		# just clone this thing.
		repo=$(echo $url | awk -F/ '{print $NF}' | sed -e 's/.git$//');
	elif [[ -z $repo ]]
	then
		# my own stuff.
		repo=$url;
		url="git@github.com:$username/$repo";
	else
		# not my own, but I know whose it is.
		url="git@github.com:$url/$repo.git";
	fi

	git clone $url $repo && cd $repo && idea .;
}

# Copy w/ progress
function cp_p () {
  rsync -WavP --human-readable --progress $1 $2
}

# Test if HTTP compression (RFC 2616 + SDCH) is enabled for a given URL.
# Send a fake UA string for sites that sniff it instead of using the Accept-Encoding header. (Looking at you, ajax.googleapis.com!)
function httpcompression() {
	encoding="$(curl -LIs -H 'User-Agent: Mozilla/5 Gecko' -H 'Accept-Encoding: gzip,deflate,compress,sdch' "$1" | grep '^Content-Encoding:')" && echo "$1 is encoded using ${encoding#* }" || echo "$1 is not using any encoding"
}

# Syntax-highlight JSON strings or files
function json() {
	if [ -p /dev/stdin ]; then
		# piping, e.g. `echo '{"foo":42}' | json`
		python -mjson.tool | pygmentize -l javascript
	else
		# e.g. `json '{"foo":42}'`
		python -mjson.tool <<< "$*" | pygmentize -l javascript
	fi
}

# prune a set of empty directories
function prunedir () {
   find $* -type d -empty -print0 | xargs -0r rmdir -p ;
}

# take this repo and copy it to somewhere else minus the .git stuff.
function gitexport(){
	mkdir -p "$1"
	git archive master | tar -x -C "$1"
}

function md() {
	mkdir -p "$@" && cd $_;
}

# get gzipped size
function gz() {
	echo "orig size    (bytes): "
	cat "$1" | wc -c
	echo "gzipped size (bytes): "
	gzip -c "$1" | wc -c
}

# All the dig info
function digga() {
	dig +nocmd "$1" any +multiline +noall +answer
}

# Escape UTF-8 characters into their 3-byte format
function escape() {
	printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
	echo # newline
}

# Decode \x{ABCD}-style Unicode escape sequences
function unidecode() {
	perl -e "binmode(STDOUT, ':utf8'); print \"$@\""
	echo # newline
}

# Add note to Notes.app (OS X 10.8)
# Usage: `note 'title' 'body'` or `echo 'body' | note`
# Title is optional
function note() {
	local title
	local body
	if [ -t 0 ]; then
			title="$1"
			body="$2"
	else
			title=$(cat)
	fi
	osascript >/dev/null <<EOF
tell application "Notes"
        tell account "iCloud"
                tell folder "Notes"
                        make new note with properties {name:"$title", body:"$title" & "<br><br>" & "$body"}
                end tell
        end tell
end tell
EOF
}

# Add reminder to Reminders.app (OS X 10.8)
# Usage: `remind 'foo'` or `echo 'foo' | remind`
function remind() {
        local text
        if [ -t 0 ]; then
                text="$1" # argument
        else
                text=$(cat) # pipe
        fi
        osascript >/dev/null <<EOF
tell application "Reminders"
        tell the default list
                make new reminder with properties {name:"$text"}
        end tell
end tell
EOF
}

# Install Grunt plugins and add them as `devDependencies` to `package.json`
# Usage: `gi contrib-watch contrib-uglify zopfli`
function gi() {
	npm install --save-dev ${*/#/grunt-}
}

# Install Gulp plugins and add them as `devDependencies` to `package.json`
# Usage: `gp uglify clean cache csso`
function gp() {
	npm install --save-dev ${*/#/gulp-}
}

# Install Yeoman generators
# Usage: `yi webapp gruntfile angular`
function yi() {
	npm install --save-dev ${*/#/generator-}
}

# `o` with no arguments opens current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
			open .
	else
			open "$@"
	fi
}

# Launch installed browsers for a specific URL
# Usage: browsers "http://www.google.com"
function browsers(){
	chrome $1
	opera $1
	firefox $1
	safari $1
}

# Browserstack shortcuts, now with added hotness thanks to the Browserstack team.
# Note, a trial or paid for account is needed for this to work
# Usage: ipad3 "http://www.google.com", win7ie8 "http://www.google.com" etc.

# For local server running on port 3000, use like this
# Usage: ipad3 "http://localhost:3000" "localhost,3000,0", win7ie8 "http://localhost:3000" "localhost,3000,0" etc.

# For local server running on apache with ssl as staging.example.com and https://staging.example.com
# Usage: ipad3 "http://staging.example.com" "staging.example.com,80,0,staging.example.com,443,1", win7ie8 "http://staging.example.com" "staging.example.com,80,0,staging.example.com,443,1" etc.

function openurl(){
	if [ $2 ]
	then
	  url=$1"&host_ports=$2"
	fi
	open -a google\ chrome ${url}
}

function androidnexus(){
	local url="http://www.browserstack.com/start#os=android&os_version=4.0.3&device=Samsung+Galaxy+Nexus&zoom_to_fit=true&url=$1&start=true"
	openurl $url $2
}

function ipad3(){
	local url="http://www.browserstack.com/start#os=ios&os_version=5.1&device=iPad+3rd&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

function ipad3ios6(){
	local url="http://www.browserstack.com/start#os=ios&os_version=6.1&device=iPad+3rd&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

function ipad2(){
	local url="http://www.browserstack.com/start#os=ios&os_version=5.1&device=iPad+2nd&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

function win7ie8(){
	local url="http://www.browserstack.com/start#os=Windows&os_version=7&browser=IE&browser_version=8.0&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

function win7ie9(){
	local url="http://www.browserstack.com/start#os=Windows&os_version=7&browser=IE&browser_version=9.0&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

function win8ie10(){
	local url="http://www.browserstack.com/start#os=Windows&os_version=8&browser=IE&browser_version=10.0&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

function winxpie8(){
	local url="http://www.browserstack.com/start#os=Windows&os_version=XP&browser=IE&browser_version=8.0&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

function winxpie7(){
	local url="http://www.browserstack.com/start#os=Windows&os_version=XP&browser=IE&browser_version=7.0&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

function winxpie6(){
	local url="http://www.browserstack.com/start#os=Windows&os_version=XP&browser=IE&browser_version=6.0&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

function win7chrome(){
	local url="http://www.browserstack.com/start#os=Windows&os_version=7&browser=Chrome&browser_version=21.0&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

function win7ff(){
	local url="http://www.browserstack.com/start#os=Windows&os_version=7&browser=Firefox&browser_version=16.0&zoom_to_fit=true&resolution=1024x768&speed=1&url=$1&start=true"
	openurl $url $2
}

# open all changed files (that still actually exist) in the editor
# credit: @cowboy
function ged() {
	local files=()
	for f in $(git diff --name-only "$@"); do
	[[ -e "$f" ]] && files=("${files[@]}" "$f")
	done
	local n=${#files[@]}
	echo "Opening $n $([[ "$@" ]] || echo "modified ")file$([[ $n != 1 ]] && \
	echo s)${@:+ modified in }$@"
	q "${files[@]}"
}

# open last commit in GitHub, in the browser.
# credit: @cowboy
function gfu() {
  local n="${@:-1}"
  n=$((n-1))
  open $(git log -n 1 --skip=$n --pretty=oneline | awk "{printf \"$(gurl)/commit/%s\", substr(\$1,1,7)}")
}
