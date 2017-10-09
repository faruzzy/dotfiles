""
"   ██╗   ██╗ ██╗ ███╗   ███╗ ██████╗   ██████╗
"   ██║   ██║ ██║ ████╗ ████║ ██╔══██╗ ██╔════╝
"   ██║   ██║ ██║ ██╔████╔██║ ██████╔╝ ██║
"   ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ██╔══██╗ ██║
" ██╗╚████╔╝  ██║ ██║ ╚═╝ ██║ ██║  ██║ ╚██████╗
" ╚═╝ ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ╚═╝  ╚═╝  ╚═════╝
"
" Author: Roland Pangu
"


"--------------------------------------------------------------------------------
" House keeping {{{
"--------------------------------------------------------------------------------

filetype plugin indent on													" Enable file type detection
syntax on																	" Syntax highlighting
syntax sync minlines=256
let mapleader=","															" Change leader to ','

set ttyfast																	" Optimize for fast terminal connections
set ttymouse=xterm2
set ttyscroll=3
set lazyredraw																" Wait to redraw, do not redraw while executing macros
set nowrap
set linebreak

" refresh current .vimrc file for change to take effect
nnoremap <leader>s :source %<CR>

" Open the current directory in finder
nnoremap <leader>O :!open .<CR>

set nocompatible															" Behave like vim and not like vi! (Much, much better)
set background=dark
set dictionary+=/usr/share/dict/words
set display=lastline
set number																	" Print the line number in front of each line
set relativenumber
set ruler																	" Display Cursor Position
set title																	" Display filename in titlebar
set titleold=																" Prevent the 'Thanks for flying Vim'
set diffopt=filler															" Add vertical spaces to keep right and left aligned
set diffopt+=iwhite															" Ignore whitespace changes (focus on code changes)
set diffopt+=vertical														" make :diffsplit default to vertical
set shell=/bin/sh															" Use /bin/sh for executing shell commands
set t_Co=256																" 256 colors terminal
set ttimeoutlen=50															" Reduce annoying delay for key codes, especially <Esc>...
set term=screen-256color
set formatoptions+=1

" Encoding {{{

set encoding=utf-8 nobomb													" BOM often causes trouble
if !has('nvim')
	set term=xterm-256color
endif

set t_ut=																	" Disable background color erase, play nicely with tmux
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,cp932,euc-jp										" A list of character encodings, set default encoding to UTF-8
set fileformats=unix,dos,mac												" Prefer Unix over Windows over OS 9 formats

" }}}

" Tab Basic Settings {{{

set autoindent																" Always set autoindenting on
set smartindent
set cindent
set expandtab																" Use the appropriate number of spaces to insert a <Tab>b
set shiftround																" Round indent to multiple of 'shiftwidth
set shiftwidth=4															" Number of spaces to use for each step of (auto)indent
set softtabstop=4															" Number of spaces that a <Tab> in the file counts for

" }}}

" Search Basic Settings {{{

set incsearch																" Display search resultings as you type
set hlsearch | nohlsearch													" Highlight search, support reloading
set ignorecase																" Ignore case in search patterns
set smartcase																" Override the ignorecase option if the pattern contains upper case
set gdefault																" By default add g flag to search/replace. Add g to toggle

" }}}

set matchpairs+=<:>															" for HTML Editing
set rnu																		"Toggle relative numbering, and set to absolute on loss of focus or insert mode

if has("gui_macvim")
  " No toolbars, menu or scrollbars in the GUI
  set guifont=Source\ Code\ Pro\ Light:h12
  set clipboard=unnamed
  set vb t_vb=
  set guioptions-=m															" no menu
  set guioptions-=T														    " no toolbar
  set guioptions-=l
  set guioptions-=L
  set guioptions-=r														    " no scrollbar
  set guioptions-=R

  let macvim_skip_colorscheme=1
  let g:molokai_original=1
  highlight SignColumn guibg=#272822
endif

" Note that these vary from language to language
set tabstop=4																" Set space width of tabs
set smarttab																" At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shifwidth spaces.
set sw=4
set splitright																" By default, split to the right
set splitbelow																" By default, split below
set binary																	" Don't add empty new lines at the end of files
set noeol
set cursorline																" Highlight current line
set nocursorcolumn

" Show "invisible" characters
"set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
"set list

set mouse=a																	" Enable mouse in all modes
set mousemodel=popup
set path=$PWD/**															" You need this (trust me) to move around
set wildmenu
set backspace=indent,eol,start
set history=1024															" Amount of Command history increased from default 20 to 1024
set noerrorbells visualbell t_vb=											" No beeps
if has('autocmd')
	autocmd GUIEnter * set visualbell t_vb=
endif
set numberwidth=2
set spelllang=en_us,fr														" Spell checking language
"set textwidth=80															" Make it obvious where 80 characters is
set cmdheight=2
set showcmd																	" Show me what I'm typing
" ================ Turn Off Swap Files ======================
set noswapfile																" No beeps
set nobackup																" Don't create annoying backup files
set nowb

set autowrite																" Automatically save before :next, :make etc.
set autoread																" Automatically reread changed files (outside of vim) without asking me anything
set laststatus=2															" Always show status line
set hidden																	" Display another buffer when current buffer isn't saved
set synmaxcol=300
set foldmethod=indent														" Enable folding
set foldlevel=99
set statusline=%<[%n]\ %F\ %m%r%y\ %{exists('g:loaded_fugitive')?fugitive#statusline():''}\ %=%-14.(%l,%c%V%)\ %P

"http://stackoverflow.com/questions/20186975/vim-mac-how-to-copy-to-clipboard-without-pbcopy
"set clipboard+=unnamed
set clipboard=unnamed														" Sets default register to be * register, which is the system clipboard. So Cmd+C and y are now the same thing; Cmd+V and p are now the same thing!"
set complete=.,w,b,u,t														" Better Completion
set completeopt=longest,menuone
set ofu=syntaxcomplete#Complete												" Set omni-completion method.
set report=0																" Show all changes

" Wildmenu completion {{{

set wildmenu																" Command line autocompletion
set wildmode=list:full														" Shows all the options
set wildignore+=.hg,.git,.svn												" Version control
set wildignore+=*.aux,*.out,*.toc											" LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg								" binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest							" compiled object files
set wildignore+=*.spl														" compiled spelling word lists
set wildignore+=*.sw?														" Vim swap files
set wildignore+=*.bak,*.?~,*.??~,*.???~,*.~									" Backup files
set wildignore+=*.DS_Store													" OSX bullshit
set wildignore+=*.luac														" Lua byte code
set wildignore+=migrations													" Django migrations
set wildignore+=go/pkg														" Go static files
set wildignore+=go/bin														" Go bin files
set wildignore+=go/bin-vagrant												" Go bin-vagrant files
set wildignore+=*.pyc														" Python byte code
set wildignore+=*.jar														" Java archives
set wildignore+=*.orig														" Merge resolution files
set wildignore+=*.stats														" Merge resolution files

" }}}

let s:darwin = has('mac')

" }}}

"--------------------------------------------------------------------------------
" Plug begins {{{
"--------------------------------------------------------------------------------
let s:first_time_launch = 0
if empty(glob("~/.vim/autoload/plug.vim"))
    silent execute '!mkdir -p ~/.vim/autoload'
    silent execute '!curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
    let s:first_time_launch = 1
endif

call plug#begin('~/.vim/plugged')

" Git {{{

Plug 'tpope/vim-fugitive'													" Git wrapper
Plug 'tpope/vim-git'														" Vim Git runtime files
Plug 'tpope/vim-rhubarb'													" GitHub extension for fugitive
Plug 'junegunn/gv.vim', { 'on': 'GV' }										" A git commint browser
if v:version >= 703
	Plug 'mhinz/vim-signify'
elseif
	Plug 'airblade/vim-gitgutter'
endif

" }}}

" Auto Completion
function! BuildYCM(info)
	" info is a dictionary with 3 fields
	" - name:   name of the plugin
	" - status: 'installed', 'updated', or 'unchanged'
	" - force:  set on PlugInstall! or PlugUpdate!
	if a:info.status == 'installed' || a:info.force
		!./install.py --clang-completer --omnisharp-completer
	endif
endfunction

Plug 'crusoexia/vim-monokai'
Plug 'cdmedia/itg_flat_vim'
Plug 'junegunn/seoul256.vim'
Plug 'morhetz/gruvbox'
"Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
Plug 'Shougo/neocomplete.vim'
Plug 'scrooloose/syntastic', { 'for': ['python', 'java', 'javascript'] }
Plug 'Shougo/unite.vim'
Plug 'tpope/vim-unimpaired'

"--------------------------------------------------------------------------------
" Go {{{
"--------------------------------------------------------------------------------

Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
"Plug 'nsf/gocode'

"--------------------------------------------------------------------------------
" }}}
"--------------------------------------------------------------------------------

"--------------------------------------------------------------------------------
" Java {{{
"--------------------------------------------------------------------------------

Plug 'udalov/javap-vim'
Plug 'udalov/kotlin-vim'

"--------------------------------------------------------------------------------
" }}}
"--------------------------------------------------------------------------------

"--------------------------------------------------------------------------------
" Python {{{
"--------------------------------------------------------------------------------

Plug 'nvie/vim-flake8'

"--------------------------------------------------------------------------------
" }}}
"--------------------------------------------------------------------------------

" HTML {{{

Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'othree/html5-syntax.vim', { 'for': 'html' }
Plug 'mattn/emmet-vim', { 'for' : ['html', 'css'] }
Plug 'gregsexton/MatchTag'															" highlight matching html tag

" }}}

" PHP {{{

Plug 'StanAngeloff/php.vim', { 'for': 'php' }										" PHP Syntax

" }}}


" ECMAScript {{{

"Plug 'Shutnik/jshint2.vim'
Plug 'mxw/vim-jsx'
Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plug 'posva/vim-vue'
Plug 'sheerun/vim-polyglot'
Plug 'HerringtonDarkholme/yats.vim'
"Plug 'leafgarland/typescript-vim'													" TypeScript Syntax support
"Plug 'Quramy/tsuquyomi'															" TypeScript Development
"Plug 'Shougo/vimproc.vim', {'do': 'make'}											" Interactive command execution in vim (dependency of 'Quramy/tsuquyomi')
"Plug 'moll/vim-node'																" Allows Node.js Development with vim
Plug 'elzr/vim-json', { 'for' : 'json' }											" json support

" }}}

" CSS {{{

Plug 'skammer/vim-css-color', { 'for': 'css' }
Plug 'groenewege/vim-less', { 'for': 'less' }
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }

" }}}

" Misc {{{

Plug 'wellle/visual-split.vim'
Plug 'wincent/loupe'																" Enhanced in-file search for Vim
Plug 'jiangmiao/auto-pairs'															" provides insert mode auto-completion for quotes, parens, brackets, etc
Plug 'easymotion/vim-easymotion'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-surround'
"Plug 'mileszs/ack.vim'
Plug 'wincent/ferret'
Plug 'jremmen/vim-ripgrep'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-vinegar'
Plug 'ryanoasis/vim-devicons'
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'sickill/vim-pasta'
Plug 'jordwalke/VimSplitBalancer'
"Plug 'dhruvasagar/vim-zoom'
Plug 'mhartington/oceanic-next'
Plug 'rakr/vim-one'
Plug 'itspriddle/ZoomWin'															" Zoom in and out of windows/buffer
Plug 'benmills/vimux'																" Easily interact with tmux from vim
Plug 'christoomey/vim-tmux-navigator'												" moving through tmux pane with ease
Plug 'tmux-plugins/vim-tmux-focus-events'											" This plugin restores `FocusGained` and `FocusLost` when using vim inside Tmux.

" }}}

call plug#end()

" }}}

colorscheme seoul256
"colorscheme monokai

" ============================================================================
" FZF {{{
" ============================================================================

" https://github.com/junegunn/fzf
set rtp+=~/.fzf

nnoremap <Leader>f :Root<CR>:FZF<CR>
nnoremap <Leader>a :Root<CR>:Ack!<Space>

if has('nvim')
  let $FZF_DEFAULT_OPTS .= ' --inline-info'
  " let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
endif

let g:fzf_files_options =
  \ '--preview "(highlight -O ansi {} || cat {}) 2> /dev/null | head -'.&lines.'"'

inoremap <expr> <c-x><c-t> fzf#complete('tmuxwords.rb --all-but-current --scroll 500 --min 5')
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

command! Plugs call fzf#run({
  \ 'source':  map(sort(keys(g:plugs)), 'g:plug_home."/".v:val'),
  \ 'options': '--delimiter / --nth -1',
  \ 'down':    '~40%',
  \ 'sink':    'Explore'})

command! FZFTag if !empty(tagfiles()) | call fzf#run({
  \   'source': "sed '/^\\!/d;s/\t.*//' " . join(tagfiles()) . ' | uniq',
  \   'sink':   'tag',
  \ }) | else | echo 'No tags' | endif

command! -bar FZFTags if !empty(tagfiles()) |
  \ call fzf#run({
  \   'source': 'sed ''/^\\!/ d; s/^\([^\t]*\)\t.*\t\(\w\)\(\t.*\)\?/\2\t\1/; /^l/ d'' ' . join(tagfiles()) . ' | uniq',
  \   'sink': function('<SID>tag_line_handler'),
  \ }) | else | call MakeTags() | FZFTags | endif

command! FZFTagsBuffer call fzf#run({
  \   'source': 'ctags -f - --sort=no ' . bufname("") . ' | sed ''s/^\([^\t]*\)\t.*\t\(\w\)\(\t.*\)\?/\2\t\1/'' | sort -k 1.1,1.1 -s',
  \   'sink': function('<SID>tag_line_handler'),
  \   'options': '--tac',
  \ })

" }}}

nnoremap <silent> <expr> <Leader><Leader> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"
nnoremap <silent> <Leader>C        :Colors<CR>
nnoremap <silent> <Leader><Enter>  :Buffers<CR>
nnoremap <silent> <Leader>ag       :Root<CR>:Ag <C-R><C-W><CR>
nnoremap <silent> <Leader>AG       :Ag <C-R><C-A><CR>
nnoremap <silent> <Leader>`        :Marks<CR>

" npm install --save-dev word under cursor
nnoremap <Leader>nd :execute ":!npm install --save-dev " . expand("<cword>")<CR>
" npm install --save word under cursor
nnoremap <Leader>n :execute ":!npm install --save " . expand("<cword>")<CR>

" Search and replace the word under the cursor
nnoremap <Leader>z :%s/\<<C-r><C-w>\>/
" Kill current buffer without closing split
nnoremap <silent> <Leader>q :bn \| bd #<CR>

let g:tmuxcomplete#trigger = 'omnifunc'
if has("autocmd")
    autocmd BufNewFile,Bufread *.json setfiletype json syntax=javascript				" Treat .json files as .js

	autocmd FileType css,sass,less set omnifunc=csscomplete#CompleteCSS
	autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
	autocmd FileType python setlocal omnifunc=pythoncomplete#CompleteTags
	autocmd FileType xml setlocal omnifunc=xmlComplete#CompleteTags

	autocmd BufNewFile,Bufread *.md setlocal filetype=markdown							" Treat .md files as Markdown
	autocmd BufNewFile,Bufread *.js setlocal filetype=javascript

	autocmd StdinReadPre * let s:std_in=1
	"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
	autocmd Filetype python call SetPythonOptions()
	"autocmd BufWritePost *.js silent :JSHint
endif

" File Type settings
au BufNewFile,Bufread *.vim setlocal noet ts=4 sw=4 sts=4
au BufNewFile,Bufread *.txt setlocal noet ts=4 sw=4
au BufNewFile,Bufread *.md setlocal noet ts=4 sw=4
au BufNewFile,Bufread *.go setlocal noet ts=4 sw=4 sts=4
autocmd BufNewFile,BufreadPost *.coffee setl shiftwidth=2 expandtab

autocmd CursorHold,CursorHoldI,FocusGained,BufEnter * checktime
autocmd FileChangedShellPost *
	\ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" python with virtualenv support
py << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  execfile(activate_this, dict(__file__=activate_this))
EOF

"augroup python3
"	au! BufEnter *.py setlocal omnifunc=python3complete#Complete
"augroup END

let python_highlight_all=1
let syntastic_mode_map = {'passive_filetypes': ['html']}

" Enable folding with the spacebar
nnoremap <space> za" Run python code by pressing F9

" tagbar installation, see:
" https://thomashunter.name/blog/installing-vim-tagbar-with-macvim-in-os-x://thomashunter.name/blog/installing-vim-tagbar-with-macvim-in-os-x/
let g:tagbar_ctags_bin='/usr/local/bin/ctags' " Proper Ctags locations
let g:tagbar_width=26	" Default is 40, seems too wide
nmap <F8> :TagbarToggle<CR>

" Split navigation "

" Better split switching (Ctrl-j, Ctrl-k, Ctrl-h, Ctrl-l) {{{

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" }}}

" Hard to type things {{{

  iabbrev >> →
  iabbrev << ←
  iabbrev ^^ ↑
  iabbrev VV ↓
  iabbrev aa λ

" }}}

" Clear last search (,qs) {{{
	map <silent> <leader>qs <Esc>:noh<CR>
" }}}

" Search and replace word under cursor (,*) {{{
    nnoremap <leader>* :%s/\<<C-r><C-w>\>//<Left>
    vnoremap <leader>* "hy:%s/\V<C-r>h//<left>
" }}}

" Convenient mappings for compiling and running quick, used mostly for school
" gcc compile C files
autocmd filetype c nnoremap <Leader>c :w <CR>:!gcc % -o %:r && ./%:r<CR>
" java compile files
autocmd filetype java nnoremap <Leader>c :w <CR>:!javac % && java %:r<CR>
" run node files
autocmd filetype javascript nnoremap <Leader>c :w <CR>:!node %<CR>
" run python files
autocmd filetype python nnoremap <Leader>c :exec '!python' shellescape(@%, 1)<CR>
" run bash files
autocmd filetype sh nnoremap <Leader>c :w <CR>:!bash %<CR>

autocmd FocusLost * call ToggleRelativeOn()
autocmd FocusGained * call ToggleRelativeOn()
autocmd InsertEnter * call ToggleRelativeOn()
autocmd InsertLeave * call ToggleRelativeOn()

au VimResized * :wincmd =																	" Resize splits when the window is resized
autocmd BufEnter * silent! cd %:p:h															" update dir to current file

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" ------------------------------------------------------------------
" Quick tab movement
" ------------------------------------------------------------------
nnoremap tf :tabfirst<CR>
nnoremap tl :tablast<CR>
nnoremap ]t :tabnext<CR>
nnoremap [t :tabprev<CR>

"------------------------------------------------------------------
" Quick Buffers movement
"------------------------------------------------------------------
nnoremap ]b :bnext<cr>
nnoremap [b :bprev<cr>

nnoremap <F12> :exec ':silent !open -a /Applications/Google\ Chrome.app %'<CR>

" Use tab to jump between blocks, because it's easier
nnoremap <tab> %
vnoremap <tab> %

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Save and close all buffer
nnoremap <leader>X :wqa!<CR>
" Close all buffer without saving
nnoremap <leader>Q :qa!<CR>
" Save and close current buffer
nnoremap <leader>x :wq!<CR>
" Close current buffer without saving
nnoremap <leader>q :q!<CR>

" Quickly open .vimrc file in the current buffer
nnoremap <leader>v :e ~/Github/dotfiles/.vimrc<CR>

" Quickly open .vimrc file in a new vertical buffer
nnoremap <leader>V :vs ~/Github/dotfiles/.vimrc<CR>

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile Appraisals set filetype=ruby
  autocmd BufRead,BufNewFile *.md set filetype=markdown

  " Enable spellchecking for Markdown
  autocmd FileType markdown setlocal spell

  " Automatically wrap at 80 characters for Markdown
  autocmd BufRead,BufNewFile *.md setlocal textwidth=80

  " Automatically wrap at 72 characters and spell check git commit messages
  autocmd FileType gitcommit setlocal textwidth=72
  autocmd FileType gitcommit setlocal spell

  " Allow stylesheets to autocomplete hyphenated words
  autocmd FileType css,scss,sass,less setlocal iskeyword+=-
augroup END

" ----------------------------------------------------------------------------
"  NeoComplete {{{
" ----------------------------------------------------------------------------

let g:neocomplete#enable_at_startup = 1										" Enabling neocomplete at startup
let g:neocomplete#enable_smart_case = 1										" Use smartcase
let g:neocomplete#sources#syntax#min_keyword_length = 3						" Set minimum syntax keyword length.

" ----------------------------------------------------------------------------
" }}}
" ----------------------------------------------------------------------------

" ----------------------------------------------------------------------------
"  YouCompleteMe {{{
" ----------------------------------------------------------------------------

let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_min_num_of_chars_for_completion = 1
let g:ycm_python_binary_path = 'python'

" for TypeScript
if !exists("g:ycm_semantic_triggers")
	let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']

" ----------------------------------------------------------------------------
" }}}
" ----------------------------------------------------------------------------

let g:jsx_ext_required = 0
" ----------------------------------------------------------------------------
" NERDTree Options {{{
" ----------------------------------------------------------------------------

map <C-c> :NERDTreeToggle<CR>
let NERDTreeChDirMode=2														" setting root dir in NT also sets VIM's cd
let NERDTreeMapOpenSplit = "s"
let NERDTreeMapOpenVSplit = "v"
let NERDTreeMinimalUI = 1
let NERDTreeShowHidden = 1
let NERDTreeChristmasTree=1													" Enable all colors for NERDTree
let NERDTreeDirArrows=1
let NERDTreeIgnore = ['\~$', '^\.git$', '^\.hg$', '^\.bundle$', '^\.jhw-cache$', '\.pyc$', '\.egg-info$', '__pycache__', '\.vagrant$', '\.dSYM$', '.DS_Store', '*.swp', '*.swo']

"autocmd vimenter * if !argc() | NERDTree | endif							" Open NERDTree if we're executing vim without specifying a file to open

let g:netrw_liststyle=3														" Explore with NerdTree Style by default
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

" Close vim tmux runner opened by VimuxRunCommand
map <Leader>vc :call VimuxCloseRunner()<CR>

" Run last command executed by VimuxRunCommand
map <Leader>vl :VimuxRunLastCommand<CR>

" Interrupt any command that is running inside the runner pane
map <Leader>vi :VimuxInterruptRunner<CR>

" Zoom the tmux runner page
map <Leader>vz :VimuxZoomRunner<CR>

" Run gulp inside runner Pane
map <Leader>gu :VimuxPromptCommand("gulp")<CR>

" Prompt for a command and run it in a small horizontal split bellow the current pane
map <Leader>vr :VimuxPromptCommand<CR>

let g:VimuxHeight = "35"

" ----------------------------------------------------------------------------
"  }}}
" ----------------------------------------------------------------------------

" ----------------------------------------------------------------------------
" tmux {{{
" ----------------------------------------------------------------------------
function! s:tmux_send(content, dest) range
  let dest = empty(a:dest) ? input('To which pane? ') : a:dest
  let tempfile = tempname()
  call writefile(split(a:content, "\n", 1), tempfile, 'b')
  call system(printf('tmux load-buffer -b vim-tmux %s \; paste-buffer -d -b vim-tmux -t %s',
        \ shellescape(tempfile), shellescape(dest)))
  call delete(tempfile)
endfunction

function! s:tmux_map(key, dest)
  execute printf('nnoremap <silent> %s "tyy:call <SID>tmux_send(@t, "%s")<cr>', a:key, a:dest)
  execute printf('xnoremap <silent> %s "ty:call <SID>tmux_send(@t, "%s")<cr>gv', a:key, a:dest)
endfunction

call s:tmux_map('<leader>tt', '')
call s:tmux_map('<leader>th', '.left')
call s:tmux_map('<leader>tj', '.bottom')
call s:tmux_map('<leader>tk', '.top')
call s:tmux_map('<leader>tl', '.right')
call s:tmux_map('<leader>ty', '.top-left')
call s:tmux_map('<leader>to', '.top-right')
call s:tmux_map('<leader>tn', '.bottom-left')
call s:tmux_map('<leader>t.', '.bottom-right')

" ----------------------------------------------------------------------------
" }}}
" ----------------------------------------------------------------------------

" ----------------------------------------------------------------------------
" Vim-go {{{
" ----------------------------------------------------------------------------

let g:go_fmt_fail_silently = 0
let g:go_fmt_command = "goimports"
let g:go_autodetect_gopath = 1
let g:go_highlight_space_tab_error = 0
let g:go_highlight_array_whitespace_error = 0
let g:go_highlight_trailing_whitespace_error = 0
let g:go_highlight_extra_types = 0
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_hightlight_operators = 1
let g:go_hightlight_build_constraints = 1

au FileType go nmap <Leader>s  <Plug>(go-def-split)
au FileType go nmap <Leader>v  <Plug>(go-def-vertical)
au FileType go nmap <Leader>in <Plug>(go-info)
au FileType go nmap <Leader>i  <Plug>(go-implements)
au FileType go nmap <leader>r  <Plug>(go-run)
au FileType go nmap <leader>b  <Plug>(go-build)
au FileType go nmap <leader>g  <Plug>(go-gbbuild)
au FileType go nmap <leader>t  <Plug>(go-test-compile)
au FileType go nmap <Leader>d  <Plug>(go-doc)
au FileType go nmap <Leader>f :GoImports<CR>

" }}}

map <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>
if executable("rg")
	let g:ackprg = 'rg --hidden -i'
elseif executable("ag")
  let g:ackprg = 'ag --nogroup --nocolor --column'
else
  let g:ackprg = 'git grep -H --line-number --no-color --untracked'
endif

" Silver Searcher {{{

augroup ag_config
  autocmd!

  if executable("ag")
    " Note we extract the column as well as the file and line number
    "set grepprg=ag\ --nogroup\ --nocolor\ --column
	set grepprg=rg\ --vimgrep
    set grepformat=%f:%l:%c%m

    " Have the silver searcher ignore all the same things as wilgignore
    "let b:ag_command = 'ag %s -i --nocolor --nogroup'
	let b:ag_command = 'rg --hidden -i'

    for i in split(&wildignore, ",")
      let i = substitute(i, '\*/\(.*\)/\*', '\1', 'g')
      let b:ag_command = b:ag_command . ' --ignore "' . substitute(i, '\*/\(.*\)/\*', '\1', 'g') . '"'
    endfor

    "let b:ag_command = b:ag_command . ' --hidden -g ""'
    let g:ctrlp_user_command = b:ag_command
  endif
augroup END

" }}}

inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" ----------------------------------------------------------------------------
" Movement in insert mode {{{
" ----------------------------------------------------------------------------

inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>a
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
inoremap <C-^> <C-o><C-^>

" move through complete suggestions with j/k
inoremap <expr> j ((pumvisible())?("\<C-n>"):("j"))
inoremap <expr> k ((pumvisible())?("\<C-p>"):("k"))

" }}}

let g:airline_theme='powerlineish'
let g:airline_powerline_fonts = 1
set noshowmode																" Don't Show the current mode Since we're using airline

" Airline.vim {{{
augroup airline_config
  autocmd!
  let g:airline_powerline_fonts = 1
  let g:airline_enable_syntastic = 1
  let g:airline#extensions#tabline#buffer_nr_format = '%s '
  let g:airline#extensions#tabline#buffer_nr_show = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#fnamecollapse = 0
  let g:airline#extensions#tabline#fnamemod = ':t'
augroup END
" }}}

" Cursorline {{{
" Only show cursorline in the current window and in normal mode.

augroup cline
	au!
	au WinLeave,InsertEnter * set nocursorline
	au WinEnter,InsertLeave * set cursorline
augroup END

" }}}

"augroup nerd_loader
"	autocmd!
"	autocmd VimEnter * silent! autocmd! FileExplorer
"	autocmd BufEnter,BufNew *
"			\  if isdirectory(expand('<amatch>'))
"			\|   call plug#load('nerdtree')
"			\|   execute 'autocmd! nerd_loader'
"			\| endif
"augroup END


" Syntastic.vim {{{

augroup syntastic_config
autocmd!
  let g:syntastic_error_symbol = '✗'
  let g:syntastic_warning_symbol = '⚠'
  let g:syntastic_ruby_checkers = ['mri', 'rubocop']
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0
  let g:syntastic_javascript_checkers = ['eslint'] " npm install -g eslint; npm install -g babel-eslint; npm install -g eslint-plugin-react
  let g:syntastic_javascript_eslint_exec = 'node_modules/eslint/bin/eslint.js' " For project-specific versions of eslint.
  let g:syntastic_javascript_eslint_exe = 'npm run eslint --'
  let g:syntastic_json_checkers = ['jsonlint']          " npm install -g jsonlint
augroup END

" }}}

let jshint2_read = 1
let jshint2_save = 1
let jshint2_min_height = 3

" ----------------------------------------------------------------------------
" Fugitive {{{
" ----------------------------------------------------------------------------

nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gm :Gmove<CR>
nnoremap <leader>gx :Gremove<CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gp :Gpush<CR>
nnoremap <leader>gc :Gcommit<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gg :Gmerge<CR>
nnoremap <leader>gv :GV<CR>
nnoremap <leader>pp :Git push origin master<CR>

" }}}

" ----------------------------------------------------------------------------
" Plug {{{
" ----------------------------------------------------------------------------

nnoremap <leader>pi :source %<CR>:PlugInstall<CR>
nnoremap <leader>pu :source %<CR>:PlugUpdate<CR>
nnoremap <leader>pU :source %<CR>:PlugUpgrade<CR>
nnoremap <leader>pc :source %<CR>:PlugClean<CR>

" ----------------------------------------------------------------------------
" }}}
" ----------------------------------------------------------------------------

let php_sql_query=1
let php_htmlInStrings=1
let g:rooter_use_lcd=1

" Typos since I suck @ typing
command! -bang E e<bang>
command! -bang Q q<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Wq wq<bang>
command! -bang WQ wq<bang>

" Removes unnecessary whitespace from otherwise blank lines in the
" current file. This is necessary to allow { and } commands to jump
" intuitively to the beginning/end of paragraphs.
" credit: https://github.com/arkwright/dotfiles/blob/master/vimrc
command! -range=% Clearblank <line1>,<line2>:global/^\s*$/normal 0D

" Copy current file name and file path to clipboard.
" credit: https://github.com/arkwright/dotfiles/blob/master/vimrc
command! CopyFilename         :let @* = expand('%:t') | echo 'Copied to clipboard: ' . @*
command! CopyPath             :let @* = expand('%:h') | echo 'Copied to clipboard: ' . @*
command! CopyAbsolutePath     :let @* = expand('%:p:h') | echo 'Copied to clipboard: ' . @*
command! CopyFilepath         :let @* = expand('%') | echo 'Copied to clipboard: ' . @*
command! CopyAbsoluteFilepath :let @* = expand('%:p') | echo 'Copied to clipboard: ' . @*

" Copy filename and filepath quick shortcuts.
nnoremap <leader>yfn :CopyFilename<CR>
xnoremap <leader>yfn :CopyFilename<CR>
nnoremap <leader>yp :CopyPath<CR>
xnoremap <leader>yp :CopyPath<CR>
nnoremap <leader>yap :CopyAbsolutePath<CR>
xnoremap <leader>yap :CopyAbsolutePath<CR>
nnoremap <leader>yfp :CopyFilepath<CR>
xnoremap <leader>yfp :CopyFilepath<CR>
nnoremap <leader>yafp :CopyAbsoluteFilepath<CR>
xnoremap <leader>yafp :CopyAbsoluteFilepath<CR>

"--------------------------------------------------------
" Custom functions {{{
"--------------------------------------------------------

" Search for the contents of the current line within the current file.
" Ignore leading/trailing punctuation (except underscore), whitespace.
" Ignore internal punctuation (except underscore).
function! FindALine()
    let l:text = getline('.')
    let l:text = substitute(l:text, "\\v^\\W+", "", "g")
    let l:text = substitute(l:text, "\\v\\W+$", "", "g")
    let l:text = substitute(l:text, "\\v\\/", "\\\\/", "g")

    execute 'normal! $/\c' . l:text . ''
endfun
nnoremap g<CR> :call FindALine()<CR>

" Use Q to intelligently close a window
function! CloseWindowOrKillBuffer()
  let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))

  " We should never bdelete a nerd tree
  if matchstr(expand("%"), 'NERD') == 'NERD'
    wincmd c
    return
  endif

  if number_of_windows_to_this_buffer > 1
    wincmd c
  else
    bdelete
  endif
endfunction
nnoremap <silent> Q :call CloseWindowOrKillBuffer()<CR>

" via: http://rails-bestpractices.com/posts/60-remove-trailing-whitespace
function! <SID>StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

command! -nargs=1 S
      \ | execute ':silent !git checkout '.<q-args>
      \ | execute ':redraw!'

command! StripTrailingWhitespaces call <SID>StripTrailingWhitespaces()
" Save a file and strip trailing white spaces
nmap <Leader>w :StripTrailingWhitespaces<CR>:w<CR>
" Save a file as root (,W) and strip trailing white spaces
noremap <leader>W :StripTrailingWhitespaces<CR>:w !sudo tee % > /dev/null<CR>

" Easy creation of Github Pull Request for current branch against master.
" credit: https://github.com/arkwright/dotfiles/blob/master/vimrc
function! s:GithubPullRequest()
  let l:placeholderRegex = '\v\C\{0\}'
  let l:httpsDomainRegex = '\v\Chttps:\/\/\zs[^\/]+\ze\/.+'
  let l:httpsRepoRegex   = '\v\Chttps:\/\/.+\/\zs.+\/.+\ze\.git'
  let l:sshDomainRegex   = '\v\C^.+\@\zs[^:\/]+\ze'
  let l:sshRepoRegex     = '\v\C^.+\@.[^:\/]+:\zs[^.]+\ze\.git'
  let l:urlTemplate      = system('echo $VIM_GITHUB_PR_URL')
  let l:remotes          = system('cd ' . expand('%:p:h') . '; git remote -v')
  let l:branch           = substitute(system('cd ' . expand('%:p:h') . '; git symbolic-ref --short -q HEAD'), '\v[\r\n]', '', 'g')
  let l:urlTemplate      = 'https://{domain}/{repo}/compare/{branch}?expand=1'

  if match(l:remotes, 'https') !=# -1
    let l:domain = matchstr(l:remotes, l:httpsDomainRegex)
    let l:repo   = matchstr(l:remotes, l:httpsRepoRegex)
  else
    let l:domain = matchstr(l:remotes, l:sshDomainRegex)
    let l:repo   = matchstr(l:remotes, l:sshRepoRegex)
  endif

  if l:domain ==# '' || l:repo ==# ''
    echoe 'Could not determine Git repo name for current file!'
  endif

  let l:prUrl = l:urlTemplate
  let l:prUrl = substitute(l:prUrl, '\v\C\{domain\}', l:domain, '')
  let l:prUrl = substitute(l:prUrl, '\v\C\{repo\}', l:repo, '')
  let l:prUrl = substitute(l:prUrl, '\v\C\{branch\}', l:branch, '')

  silent exec "!open '" . shellescape(l:prUrl, 1) . "'"
endfunction
command! PR :call s:GithubPullRequest()function! s:tag_line_handler(l)

" Find any URL on the current line, and open it in a web browser.
" Adapted from: http://stackoverflow.com/questions/9458294/open-url-under-cursor-in-vim-with-browser
" Add the following environment variable to your shell configuration to enable JIRA ticket support:
" export VIM_JIRA_URL=https://your-jira-domain-goes-here.com/browse/{0}
function! BrowserOpen()
  let l:line = getline('.')
  let l:urlRegex = '\v\C[a-z]*:\/\/[^ >,;)]*'

  let l:uri = matchstr(l:line, l:urlRegex)

  if l:uri != ""
    silent exec "!open '" . shellescape(l:uri, 1) . "'"
    return
  endif

  let l:jiraRegex = '\v\C[A-Z]+-\d+'
  let l:jiraUrlPlaceholderRegex = '\v\C\{0\}'

  let l:jiraTicket = matchstr(l:line, l:jiraRegex)

  if l:jiraTicket != ""
    let l:jiraUrl = system('echo $VIM_JIRA_URL')
    let l:jiraUrl = substitute(l:jiraUrl, l:jiraUrlPlaceholderRegex, l:jiraTicket, 'g')
    silent exec "!open '" . shellescape(l:jiraUrl, 1) . "'"
    return
  endif

  echo "No URI or JIRA ticket number found in line."
endfunction
nnoremap gx :call BrowserOpen()<CR>
xnoremap gx :call BrowserOpen()<CR>

function! s:tag_line_handler(l)
	let keys = split(a:l, '\t')
	exec 'tag' keys[1]
endfunction

function! MakeTags()
	echo 'Preparing tags...'
	call system('ctags -R')
	echo 'Tags done'
endfunction

" Handy function to switch between current
" and previous buffer
function! SwitchBuffer()
	b#
endfunction
nmap b<Tab> :call SwitchBuffer()<CR>

" Sets python options
function! SetPythonOptions()
	setlocal tabstop=4
	setlocal softtabstop=4
	setlocal shiftwidth=4
	setlocal textwidth=80
	setlocal smarttab
	setlocal expandtab
	setlocal autoindent
	set fileformat=unix
endfunction

function! ToggleNumbersOn()
	set nu!
	set rnu
endfunction

function! ToggleRelativeOn()
	set rnu!
	set nu
endfunction

" ----------------------------------------------------------------------------
" <Leader>?/! | Google it / Feeling lucky {{{
" ----------------------------------------------------------------------------
function! s:goog(pat, lucky)
  let q = '"'.substitute(a:pat, '["\n]', ' ', 'g').'"'
  let q = substitute(q, '[[:punct:] ]',
	   \ '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
  call system(printf('open "https://www.google.com/search?%sq=%s"',
				   \ a:lucky ? 'btnI&' : '', q))
endfunction

nnoremap <leader>? :call <SID>goog(expand("<cWORD>"), 0)<cr>
nnoremap <leader>! :call <SID>goog(expand("<cWORD>"), 1)<cr>
xnoremap <leader>? "gy:call <SID>goog(@g, 0)<cr>gv
xnoremap <leader>! "gy:call <SID>goog(@g, 1)<cr>gv

" }}}

" ----------------------------------------------------------------------------
" :Root | Change directory to the root of the Git repository {{{
" ----------------------------------------------------------------------------
function! s:root()
  let root = systemlist('git rev-parse --show-toplevel')[0]
  if v:shell_error
	echo 'Not in git repo'
  else
	execute 'lcd' root
	echo 'Changed directory to: '.root
  endif
endfunction
command! Root call s:root()

" }}}

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
function! InsertTabWrapper()
	let col = col('.') - 1
	if !col || getline('.')[col - 1] !~ '\k'
		return "\<tab>"
	else
		return "\<c-p>"
	endif
endfunction

" }}}

function! PhpSyntaxOverride()
	hi! def link phpDocTags  phpDefine
	hi! def link phpDocParam phpType
endfunction

augroup phpSyntaxOverride
	autocmd!
	autocmd FileType php call PhpSyntaxOverride()
augroup END