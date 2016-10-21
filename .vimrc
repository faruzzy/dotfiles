""
"   ██╗   ██╗ ██╗ ███╗   ███╗ ██████╗   ██████╗
"   ██║   ██║ ██║ ████╗ ████║ ██╔══██╗ ██╔════╝
"   ██║   ██║ ██║ ██╔████╔██║ ██████╔╝ ██║
"   ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ██╔══██╗ ██║
" ██╗╚████╔╝  ██║ ██║ ╚═╝ ██║ ██║  ██║ ╚██████╗
" ╚═╝ ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ╚═╝  ╚═╝  ╚═════╝
" 
"

"--------------------------------------------------------------------------------
" House keeping {{{
"--------------------------------------------------------------------------------

set ttyfast							" Optimize for fast terminal connections
set ttymouse=xterm2
set ttyscroll=3
set lazyredraw						" Wait to redraw, do not redraw while executing macros
set linebreak

syntax on							" Syntax highlighting
let mapleader=","					" Change leader to ','
" refresh current .vimrc file for change to take effect
nnoremap <leader>s :source %<CR>
set nocompatible					" Behave like vim and not like vi! (Much, much better)
set background=dark
set number							" Print the line number in front of each line
set ruler							" Display Cursor Position
set title							" Display filename in titlebar
set titleold=						" Prevent the 'Thanks for flying Vim'
set relativenumber
set diffopt+=vertical				" make :diffsplit default to vertical

let s:darwin = has('mac')

" }}}

"--------------------------------------------------------------------------------
" Plug begins {{{
"--------------------------------------------------------------------------------

call plug#begin('~/.vim/plugged')

" Git
Plug 'gregsexton/gitv', { 'on': 'Gitv' }
Plug 'tpope/vim-fugitive'
if v:version >= 703
	Plug 'mhinz/vim-signify'
elseif
	Plug 'airblade/vim-gitgutter'
endif
Plug 'junegunn/gv.vim'
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
Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
Plug 'Shougo/neocomplete.vim'
Plug 'benmills/vimux'

" Lang "
" ==== Go ==== "
Plug 'garyburd/go-explorer'
Plug 'fatih/vim-go'
Plug 'nsf/gocode'
"Plug 'Shougo/vimproc.vim'
Plug 'Shougo/unite.vim'

" ====== Java ====== "
Plug 'udalov/javap-vim'
Plug 'udalov/kotlin-vim'

" ==== Python ==== "
Plug 'scrooloose/syntastic'
Plug 'nvie/vim-flake8'

" Web Development "
" ==== HTML ==== "
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'othree/html5-syntax.vim', { 'for': 'html' }
Plug 'mattn/emmet-vim', { 'for' : ['html', 'css'] }
Plug 'digitaltoad/vim-jade', { 'for': 'jade' }

" highlight matching html tag
Plug 'gregsexton/MatchTag'

" Syntax
Plug 'StanAngeloff/php.vim', { 'for': 'php' }

" ==== ECMAScript ==== "
"Plug 'Shutnik/jshint2.vim'
Plug 'pangloss/vim-javascript', {'for': 'javascript'}
Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plug 'othree/yajs.vim', { 'for': 'javascript' }
Plug 'othree/jspc.vim', { 'for': 'javascript' }
Plug 'nono/jquery.vim', { 'for': 'javascript' }

Plug 'mxw/vim-jsx'									" After syntax, ftplugin, indent for JSX
Plug 'bigfish/vim-js-context-coloring'
Plug 'sheerun/vim-polyglot'
Plug 'kchmck/vim-coffee-script'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'leafgarland/typescript-vim'					" TypeScript Syntax support
Plug 'Quramy/tsuquyomi'								" TypeScript Development
Plug 'Shougo/vimproc.vim', {'do': 'make'}			" Interactive command execution in vim (dependency of 'Quramy/tsuquyomi')
Plug 'moll/vim-node'								" Allows Node.js Development with vim
Plug 'elzr/vim-json', { 'for' : 'json' }			" json support
" ==== ECMAScript ==== "

" ==== CSS ==== "
Plug 'skammer/vim-css-color', { 'for': 'css' }
Plug 'groenewege/vim-less', { 'for': 'less' }
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
" ==== CSS ==== "

" Misc
Plug 'easymotion/vim-easymotion'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-surround'
Plug 'mileszs/ack.vim'
Plug 'junegunn/vim-pseudocl'
Plug 'junegunn/vim-oblique'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'ryanoasis/vim-devicons'
Plug 'plasticboy/vim-markdown'
Plug 'sickill/vim-pasta'

call plug#end()

" }}}

colo seoul256
"colorscheme monokai
"colorscheme hybrid
"colorscheme gruvbox
"colorscheme itg_flat

set t_Co=256
set formatoptions+=1
" ============================================================================
" FZF {{{
" ============================================================================

" https://github.com/junegunn/fzf
set rtp+=~/.fzf

nnoremap <Leader>f :FZF<CR>
map <leader>a :Ack!<Space>

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


" nnoremap <silent> <Leader><Leader> :Files<CR>
nnoremap <silent> <expr> <Leader><Leader> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"
nnoremap <silent> <Leader>C        :Colors<CR>
nnoremap <silent> <Leader><Enter>  :Buffers<CR>
nnoremap <silent> <Leader>ag       :Ag <C-R><C-W><CR>
nnoremap <silent> <Leader>AG       :Ag <C-R><C-A><CR>
nnoremap <silent> <Leader>`        :Marks<CR>
" nnoremap <silent> q: :History:<CR>
" nnoremap <silent> q/ :History/<CR>

if has('patch-7.3.541')
	set formatoptions+=j
endif

if has('patch-7.4.338')
	let &showbreak = '↳ '
	set breakindent
	set breakindentopt=sbr
endif
"
" use 256 colors in terminal
if !has("gui_running")
    set t_Co=256
    set term=screen-256color
endif

if has("gui_macvim")
  " No toolbars, menu or scrollbars in the GUI
  set guifont=Source\ Code\ Pro\ Light:h12
  set clipboard+=unnamed
  set vb t_vb=
  set guioptions-=m  "no menu
  set guioptions-=T  "no toolbar
  set guioptions-=l
  set guioptions-=L
  set guioptions-=r  "no scrollbar
  set guioptions-=R

  let macvim_skip_colorscheme=1
  let g:molokai_original=1
  highlight SignColumn guibg=#272822
endif

if has("autocmd")
    " Enable file type detection
    filetype on                  
    filetype plugin indent on    

    " Treat .json files as .js
    autocmd BufNewFile,Bufread *.json setfiletype json syntax=javascript

	autocmd BufNewFile,BufRead *.less set filetype=less
	autocmd FileType less set omnifunc=csscomplete#CompleteCSS
	autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

    " Treat .md files as Markdown
    autocmd BufNewFile,Bufread *.md setlocal filetype=markdown

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

" python with virtualenv support
py << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  execfile(activate_this, dict(__file__=activate_this))
EOF

let python_highlight_all=1

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Enable folding with the spacebar
nnoremap <space> za" Run python code by pressing F9

" tagbar installation, see:
" https://thomashunter.name/blog/installing-vim-tagbar-with-macvim-in-os-x://thomashunter.name/blog/installing-vim-tagbar-with-macvim-in-os-x/ 
let g:tagbar_ctags_bin='/usr/local/bin/ctags' " Proper Ctags locations
let g:tagbar_width=26	" Default is 40, seems too wide
nmap <F8> :TagbarToggle<CR>

" Split navigation "

" Ctrl-j move to the split below
nnoremap <C-J> <C-W><C-J>
" Ctrl-k move to the split above
nnoremap <C-K> <C-W><C-K>
" Ctrl-l move to the split to the right
nnoremap <C-L> <C-W><C-L>
" Ctrl-h move to the split to the left
nnoremap <C-H> <C-W><C-H>

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

" Tab Basic Settings {{{

set autoindent					" Alwasy set autoindenting on
set expandtab					" Use the appropriate number of spaces to insert a <Tab>b
set smartindent
set shiftround					" Round indent to multiple of 'shiftwidth
set shiftwidth=4				" Number of spaces to use for each step of (auto)indent
set softtabstop=4				" Number of spaces that a <Tab> in the file counts for

" }}}

" Search Basic Settings {{{

set incsearch					" Display search resultings as you type
set hlsearch | nohlsearch		" Highlight search, support reloading
set ignorecase					" Ignore case in search patterns
set smartcase					" Override the ignorecase option if the pattern contains upper case

" }}}

" HTML Editing
set matchpairs+=<:>

"Toggle relative numbering, and set to absolute on loss of focus or insert mode
set rnu

autocmd FocusLost * call ToggleRelativeOn()
autocmd FocusGained * call ToggleRelativeOn()
autocmd InsertEnter * call ToggleRelativeOn()
autocmd InsertLeave * call ToggleRelativeOn()

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
nnoremap <leader>X :wqa!<cr>
" Close all buffer without saving
nnoremap <leader>Q :qa!<cr>
" Save and close current buffer
nnoremap <leader>x :wq!<cr>
" Close current buffer without saving
nnoremap <leader>q :q<cr>
" Quickly save current buffer
nnoremap <leader>w :w<cr>

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

  " autocmd BufRead *.jsx set ft=jsx.html
  " autocmd BufNewFile *.jsx set ft=jsx.html

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

"set t_Co=16

" Note that these vary from language to language
set tabstop=4   "Set space width of tabs
set smarttab    "At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shifwidth spaces.
set sw=4

set splitright  "By default, split to the right
set splitbelow

" Don't add empty new lines at the end of files
set binary
set noeol

" Highlight current line
set cursorline
set nocursorcolumn

" Show "invisible" characters
"set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
"set list


" ------------------
set mouse=a    "Enable mouse in all modes
set mousemodel=popup
"set paste																	" Option to aid in pasting text unmodified from other applications
set path=$PWD/**															" You need this (trust me) to move around
set wildmenu
set backspace=indent,eol,start
set history=1024															" Amount of Command history
set noerrorbells															" No beeps
set numberwidth=2
set spelllang=en,fr															" Spell checking language
"set textwidth=80															" Make it obvious where 80 characters is
set cmdheight=2
set showcmd																	" Show me what I'm typing
set noshowmode																" Don't Show the current mode Since we're using airline
set noswapfile																" No beeps
set nobackup																" Don't create annoying backup files
set autowrite																" Automatically save before :next, :make etc.
set autoread																" Automatically reread changed files (outside of vim) without asking me anything
set laststatus=2															" Always show status line
set hidden																	" Display another buffer when current buffer isn't saved

syntax sync minlines=256
set synmaxcol=300

set foldmethod=indent														" Enable folding
set foldlevel=99

set statusline=%<[%n]\ %F\ %m%r%y\ %{exists('g:loaded_fugitive')?fugitive#statusline():''}\ %=%-14.(%l,%c%V%)\ %P

" ----------------------------------------------------------------------------
" Encoding {{{
" ----------------------------------------------------------------------------

set encoding=utf-8   
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,cp932,euc-jp										" A list of character encodings, set default encoding to UTF-8
set fileformats=unix,dos,mac												" Prefer Unix over Windows over OS 9 formats

" }}}

"http://stackoverflow.com/questions/20186975/vim-mac-how-to-copy-to-clipboard-without-pbcopy
set clipboard=unnamed
set complete=.,w,b,u,t														" Better Completion
set completeopt=longest,menuone
set ofu=syntaxcomplete#Complete												" Set omni-completion method.
set report=0																" Show all changes


" ----------------------------------------------------------------------------
" Wildmeu completion {{{
" ----------------------------------------------------------------------------

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

" ----------------------------------------------------------------------------
"  NeoComplete {{{
" ----------------------------------------------------------------------------

let g:neocomplete#enable_at_startup = 1										" Enabling neocomplete at startup
let g:neocomplete#enable_smart_case = 1										" Use smartcase
let g:neocomplete#sources#syntax#min_keyword_length = 3						" Set minimum syntax keyword length.

" }}}

" ----------------------------------------------------------------------------
"  YouCompleteMe {{{
" ----------------------------------------------------------------------------

let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_min_num_of_chars_for_completion = 1

" for TypeScript
if !exists("g:ycm_semantic_triggers")
	let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']

" }}}

" ----------------------------------------------------------------------------
" NERDTree Options {{{
" ----------------------------------------------------------------------------

let NERDTreeIgnore=['CVS','\.dSYM$', '.git', '.DS_Store', '*.swp', '*.swo', '*.swo']
let NERDTreeChDirMode=2														" setting root dir in NT also sets VIM's cd

"noremap <Leader>n :<C-u>call g:NerdTreeFindToggle()<cr>					" For toggling
map <C-c> :NERDTreeToggle<CR>
"nmap <silent> <leader>n :NERDTreeToggle<CR>
let NERDTreeMapOpenSplit = "s"
let NERDTreeMapOpenVSplit = "v"
let NERDTreeMinimalUI = 1
let NERDTreeShowHidden = 1
let NERDTreeIgnore = ['\~$', '^\.git$', '^\.hg$', '^\.bundle$', '^\.jhw-cache$', '\.pyc$', '\.egg-info$', '__pycache__', '\.vagrant$']

" These prevent accidentally loading files while focused on NERDTree
"autocmd FileType nerdtree noremap <buffer> <c-left> <nop>
"autocmd FileType nerdtree noremap <buffer> <c-h> <nop>
"autocmd FileType nerdtree noremap <buffer> <c-right> <nop>
"autocmd FileType nerdtree noremap <buffer> <c-l> <nop>

" Open NERDTree if we're executing vim without specifying a file to open
autocmd vimenter * if !argc() | NERDTree | endif

" Hides "Press ? for help"
let NERDTreeMinimalUI=1
let g:NERDTreeShowHidden=1													" Shows invisibles
let g:netrw_liststyle=3														" Explore with NerdTree Style by default

"Plugin 'jistr/vim-nerdtree-tabs'
"map <silent> <Leader>n <plug>NERDTreeTabsToggle<CR>

" }}}

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

au FileType go nmap <Leader>s <Plug>(go-def-split)
au FileType go nmap <Leader>v <Plug>(go-def-vertical)
au FileType go nmap <Leader>in <Plug>(go-info)
au FileType go nmap <Leader>i <Plug>(go-implements)
au FileType go nmap <leader>r  <Plug>(go-run)
au FileType go nmap <leader>b  <Plug>(go-build)
au FileType go nmap <leader>g  <Plug>(go-gbbuild)
au FileType go nmap <leader>t  <Plug>(go-test-compile)
au FileType go nmap <Leader>d <Plug>(go-doc)
au FileType go nmap <Leader>f :GoImports<CR>

" }}}

map <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>
if executable("ag")
  let g:ackprg = 'ag --nogroup --nocolor --column'
else
  let g:ackprg = 'git grep -H --line-number --no-color --untracked'
endif

inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" ----------------------------------------------------------------------------
" Movement in insert mode {{{
" ----------------------------------------------------------------------------

inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>a
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
inoremap <C-^> <C-o><C-^>

" }}}

let g:airline_theme='powerlineish'
let g:airline_powerline_fonts = 1

"let jshint2_read = 1
"let jshint2_save = 1
"let jshint2_min_height = 3

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
nnoremap <leader>pp :Git push origin master<CR>

" }}}

" ----------------------------------------------------------------------------
" Plug {{{
" ----------------------------------------------------------------------------

nnoremap <leader>pi :PlugInstall<CR>
nnoremap <leader>pu :PlugUpdate<CR>
nnoremap <leader>pU :PlugUpgrade<CR>
nnoremap <leader>pc :PlugClean<CR>

" }}}

let php_sql_query=1
let php_htmlInStrings=1
let g:rooter_use_lcd=1

au VimResized * :wincmd =											" Resize splits when the window is resized
autocmd BufEnter * silent! cd %:p:h									" update dir to current file

" Typos since I suck @ typing
command! -bang E e<bang>
command! -bang Q q<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Wq wq<bang>
command! -bang WQ wq<bang>

"--------------------------------------------------------
" Custom functions {{{
"--------------------------------------------------------

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

" Strip trailing whitespace (,ss)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>

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