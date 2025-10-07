#!/usr/bin/env zsh

# Github pull request
function ghpr() {
  local sed_cmd=$( [ "$(uname)" = Darwin ] && echo 'sed -E' || echo 'sed -r' )
  local PR=${1}
  local REPO_SLUG="$(git config --get remote.upstream.url \
        | sed 's/^.*github.com[\/:]\(.*\)\.git/\1/')"
  local req_url="https://api.github.com/repos/${REPO_SLUG}/pulls/${PR}"
  local PR_TITLE="$(curl -Ss "$req_url" \
        | grep '"title"' \
        | $sed_cmd 's/.*(\[(RFC|RDY)\]) *(.*)../\3/')"

  [ -z "$PR_TITLE" ] && { printf "error. request: $req_url\n       response: $(curl -Ss $req_url)\n"; return 1; }

  git fetch --all --prune \
    && git checkout master \
    && git stash save autosave-$(date +%Y%m%d_%H%M%S) \
    && git reset --hard upstream/master \
    && git merge --no-commit --no-ff -m "Merge #${PR} '${PR_TITLE}'" refs/pull/upstream/${PR}
}

function ghrebase1() {
  local PR=${1}
  local sed_cmd=$( [ "$(uname)" = Darwin ] && echo 'sed -E' || echo 'sed -r' )

  #FOO=bar nvim -c 'au VimEnter * Gcommit --amend' -s <(echo 'Afoo')
  git fetch --all --prune \
    && git checkout --quiet refs/pull/upstream/${PR} \
    && git rebase upstream/master \
    && git checkout master \
    && git stash save autosave-$(date +%Y%m%d_%H%M%S) \
    && git reset --hard upstream/master \
    && git merge --ff-only - \
    && git commit --amend -m "$(git log -1 --pretty=format:"%B" \
              | $sed_cmd "1 s/^(.*)\$/\\1 #${PR}/g")" \
    && git log --oneline --graph --decorate -n 5
}

# fshow - git commit browser (enter for show, ctrl-d for diff, ctrl-s toggles sort)
# thanks to https://gist.github.com/junegunn/f4fca918e937e6bf5bad?permalink_comment_id=1666125#gistcomment-1666125
fshow() {
  local out q k sha
  while out=$(
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)" "$@" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --header=$'ENTER (show) ╱ CTRL-D (diff) \n' \
        --bind=ctrl-s:toggle-sort \
        --expect=ctrl-d);
  do
    q=$(head -1 <<< "$out")
    k=$(head -2 <<< "$out" | tail -1)
    sha=$(tail -1 <<< "$out" | grep -o '[a-f0-9]\{7\}' | head -1)
    [ -z "$sha" ] && continue
    if [ "$k" = 'ctrl-d' ]; then
      git diff $sha
    else
      git show --color=always $sha | less -R
    fi
  done
}

# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
function fstash() {
  local out q k sha
  while out=$(
    git stash list --color=always --format="%C(yellow)%h %C(green)%>(14)%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --header=$'ENTER (show) ╱ CTRL-D (diff) ╱ CTRL-B (branch) ╱ CTRL-X (drop)\n' \
        --expect=ctrl-d,ctrl-b,ctrl-x);
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
      elif [ "$k" = 'ctrl-x' ]; then
        git stash drop $sha
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


# fco - checkout git branch/tag
function fco() {
  local tags branches target
  tags=$(git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") |
    fzf-tmux -l40 -- --no-hscroll --ansi +m -d "\t" -n 2 -1 -q "$*") || return
  git checkout $(echo "$target" | awk '{print $2}')
}

# fbr - checkout git branch
function fbr() {
  local branches branch
  branches=$(git branch) &&
  branch=$(echo "$branches" | fzf-tmux -d 15 +m) &&
  git checkout $(echo "$branch" | sed "s/.* //")
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

# dd - cd to selected directory
function dd() {
  DIR=`find ${1:-*} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf-tmux` \
    && cd "$DIR"
}

# dda - including hidden directories
function dda() {
  DIR=`find ${1:-.} -type d 2> /dev/null | fzf-tmux` && cd "$DIR"
}

# Function to list directories, can take an argument for depth or path
function lsd() { find "${1:-.}" -maxdepth "${2:-1}" -type d -not -name '.*'; }

# List only hidden files (using find)
function lsh() { find "${1:-.}" -maxdepth "${2:-1}" -type f -name '.*'; }

# ZSH: Custom fuzzy completion for "docker" command (converted from bash completion)
# Added: zsh-style completion function
function _fzf_complete_docker() {
  local context state line
  ARGS="$@"
  if [[ $ARGS = 'docker ** docker' ]]; then
    _values 'docker commands' \
        'images[list images]' \
        'inspect[inspect container/image]' \
        'ps -a[list all containers]' \
        'rmi -f[force remove images]' \
        'rm[remove containers]' \
        'stop[stop containers]' \
        'start[start containers]'
  elif [[ $ARGS = 'docker ** rmi' || $ARGS = 'docker ** -f' ]]; then
    local images
    images=(${(f)"$(docker images --format '{{.Repository}}:{{.Tag}}')"})
    _values 'docker images' $images
  elif [[ $ARGS = 'docker ** start' || $ARGS = 'docker ** stop' || $ARGS = 'docker ** rm' ]]; then
    local containers
    containers=(${(f)"$(docker ps -a --format '{{.Names}}')"})
    _values 'docker containers' $containers
  fi
}

# ZSH: Register the completion function
# Added: Check if compdef exists before using it
if [[ -n "$ZSH_VERSION" ]] && (( $+functions[compdef] )); then
  compdef _fzf_complete_docker docker
fi

# https://gist.github.com/premek/6e70446cfc913d3c929d7cdbfe896fef
# Usage: mv oldfilename
# If you call mv without the second parameter it will prompt you to edit the filename on command line.
# Original mv is called when it's called with more than one argument.
# It's useful when you want to change just a few letters in a long name.
function mv() {
  if [ "$#" -ne 1 ]; then
    command mv "$@"
    return
  fi
  if [ ! -f "$1" ]; then
    command file "$@"
    return
  fi

  # ZSH: Use vared instead of read -e for line editing
  local newfilename="$1"
  vared -p "New filename: " newfilename
  mv -v "$1" "$newfilename"
}

# Create a .tart.gz archive, using zopfli, pigz or gzip for compression
function targz() {
  local tmpFile="${@%/}.tar"
  tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1

  size=$(
    stat -f"%z" "${tmpFile}" 2>/dev/null # macOS `stat`
    stat -c"%s" "${tmpFile}" 2>/dev/null # GNU `stat`
  )

  local cmd=""
  if ((size < 52428800)) && hash zopfli 2>/dev/null; then
    # the .tar file is smaller than 50 MB and Zopfli is available; use it
    cmd="zopfli"
  else
    if hash pigz 2>/dev/null; then
      cmd="pigz"
    else
      cmd="gzip"
    fi
  fi

  echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…"
  "${cmd}" -v "${tmpFile}" || return 1
  [ -f "${tmpFile}" ] && rm "${tmpFile}"

  zippedSize=$(
    stat -f"%z" "${tmpFile}.gz" 2>/dev/null # macOS `stat`
    stat -c"%s" "${tmpFile}.gz" 2>/dev/null # GNU `stat`
  )

  echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully."
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
      # ZSH: Use read -q for yes/no prompts
      echo "$foldername already exists, do you want to overwrite it? (y/n)"
      if ! read -q; then
        echo
        return
      fi
      echo
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
  sep='{::}'

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

# Create a data URL from a file
function dataurl() {
  local mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Copy w/ progress
function cp_p () {
  rsync -WavP --human-readable --progress $1 $2
}

# prune a set of empty directories
function prunedir () {
   find $* -type d -empty -print0 | xargs -0r rmdir -p ;
}

# Zoxide integration (replaces the old z function)
# Note: Make sure zoxide is initialized in your .zshrc with: eval "$(zoxide init zsh)"
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

# This function provides fzf integration with zoxide
function zi() {
  local result
  result=$(zoxide query -l | fzf --height 40% --reverse --inline-info +s --tac --query "$*")
  if [[ -n "$result" ]]; then
    cd "$result"
  fi
}

# Launch installed browsers for a specific URL
# Usage: browsers "http://www.google.com"
function browsers(){
  chrome $1
  firefox $1
  safari $1
}

fzf-down() {
  fzf --height 50% "$@" --border
}

_gp() {
  ps -ef | fzf-down --header-lines 1 --info inline --layout reverse --multi |
    awk '{print $2}'
}

_gg() {
  zoxide query -l | fzf --height 40% --reverse --inline-info --tac
}

RG() {
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="$1"
  local selected=$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY' || true" \
      fzf --bind "change:reload:$RG_PREFIX {q} || true" \
          --ansi --disabled --query "$INITIAL_QUERY" \
          --delimiter : \
          --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
          --preview-window '~3:+{2}+3/2'
  )
  [ -n "$selected" ] && $EDITOR "$selected"
}

# ZSH: Key bindings (converted from bash bind commands)
# Note: Make sure you have fzf-git.sh sourced for these to work
if [[ -f ~/fzf-git.sh ]]; then
  source ~/fzf-git.sh
fi

# ZSH: Widget functions for key bindings
_gp_widget() {
  local result=$(_gp)
  LBUFFER+="$result"
  zle reset-prompt
}

_gg_widget() {
  local result=$(_gg)
  if [[ -n "$result" ]]; then
    cd "$result"
    zle reset-prompt
    zle -R  # Force redraw
    print -r ""  # Print newline
  fi
}

_fe_widget() {
  # Save current line state
  local saved_buffer="$BUFFER"
  local saved_cursor="$CURSOR"

  # Clear the command line for fzf
  BUFFER=""
  CURSOR=0
  zle redisplay

  # Call fe function and capture result
  local file
  file=$(fzf-tmux --preview 'bat -n --color=always {}' --select-1 --exit-0 </dev/tty)

  if [ -n "$file" ]; then
    # Open the file with neovim explicitly
    nvim "$file" </dev/tty >/dev/tty 2>&1
  fi

  # Restore the command line
  BUFFER="$saved_buffer"
  CURSOR="$saved_cursor"
  zle redisplay
}

_rg_widget() {
  RG ""
  zle reset-prompt
}

# ZSH: Create zle widgets and bind keys
zle -N _gp_widget
zle -N _gg_widget
zle -N _fe_widget
zle -N _rg_widget

bindkey '^G^P' _gp_widget
bindkey '^G^G' _gg_widget
bindkey '^P' _fe_widget
bindkey '^[f' _rg_widget
