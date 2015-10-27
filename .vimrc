"set nocompatible    "Behave like vim and not like vi! (Much, much better)
colorscheme hybrid
set background=dark
let python_highlight_all=1
syntax on

call plug#begin('~/.vim/plugged')

" Git
Plug 'gregsexton/gitv', { 'on': 'Gitv' }
Plug 'tpope/vim-fugitive'
if v:version >= 703
	Plug 'mhinz/vim-signify'
elseif
	Plug 'airblade/vim-gitgutter'
endif

" Lang "
Plug 'plasticboy/vim-markdown'
Plug 'fatih/vim-go'
Plug 'garyburd/go-explorer'
" Python
Plug 'scrooloose/syntastic'
Plug 'nvie/vim-flake8'

" Web Development
Plug 'mattn/emmet-vim', { 'for' : ['html', 'css'] }
Plug 'skammer/vim-css-color', {'for': 'css'}
Plug 'Shutnik/jshint2.vim'
Plug 'groenewege/vim-less'
Plug 'pangloss/vim-javascript'
Plug 'kchmck/vim-coffee-script'
Plug 'elzr/vim-json', {'for' : 'json'}
Plug 'digitaltoad/vim-jade', {'for': 'jade'}
Plug 'jaxbot/browserlink.vim'

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
Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
Plug 'Shougo/neocomplete.vim'

" Misc
Plug 'easymotion/vim-easymotion'
Plug 'bling/vim-airline'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
Plug 'tpope/vim-surround'
Plug 'mileszs/ack.vim'
Plug 'junegunn/vim-pseudocl'
Plug 'junegunn/vim-oblique'

call plug#end()

set formatoptions+=1
if has('patch-7.3.541')
	set formatoptions+=j
endif
if has('patch-7.4.338')
	let &showbreak = '↳ '
	set breakindent
	set breakindentopt=sbr
endif

if has("autocmd")
    " Enable file type detection
    filetype on                  
    filetype plugin indent on    

    " Treat .json files as .js
    autocmd BufNewFile,Bufread *.json setfiletype json syntax=javascript

    " Treat .md files as Markdown
    autocmd BufNewFile,Bufread *.md setlocal filetype=markdown

	autocmd StdinReadPre * let s:std_in=1
	autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
	autocmd Filetype python call SetPythonOptions()
	"autocmd BufWritePost *.js silent :JSHint
endif

" python with virtualenv support
py << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  execfile(activate_this, dict(__file__=activate_this))
EOF

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

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Enable folding with the spacebar
nnoremap <space> za" Run python code by pressing F9

nnoremap <buffer> <F9> :exec '!python' shellescape(@%, 1)<cr>

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
" node run files
autocmd filetype javascript nnoremap <Leader>c :w <CR>:!node %<CR>

set autoindent      "alwasy set autoindenting on
set smartindent

set t_Co=16

" Note that these vary from language to language
set tabstop=4   "Set space width of tabs
set smarttab    "At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shifwidth spaces.
set shiftwidth=4 "And again, relate
set softtabstop=4
set expandtab
set sw=4

set splitright  "By default, split to the right
set splitbelow

set ruler       "Display Cursor Position

" Don't add empty new lines at the end of files
set binary
set noeol

" Highlight current line
set cursorline
set nocursorcolumn

set title       "Display filename in titlebar
set titleold=   "Prevent the "Thanks for flying Vim"

" Show "invisible" characters
"set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
"set list


" Search options
set incsearch   "Display search resultings as you type
set hlsearch    "Highlight search
set ignorecase
set smartcase
" Optimize for fast terminal connections
set ttyfast
set ttymouse=xterm2
set ttyscroll=3
set lazyredraw          	    " Wait to redraw "

" ------------------
set mouse=a    "Enable mouse in all modes

" Option to aid in pasting text unmodified from other applications
"set paste

set wildmenu

set backspace=indent,eol,start
set history=100

" Settings

"No beeps
set noerrorbells	"No beeps 

"Add line numbers
set number      

set relativenumber

"Show me what I'm typing
set showcmd	    

"Don't Show the current mode Since we're using airline
set noshowmode    

set noswapfile                  " No beeps
set nobackup                    " Don't create annoying backup files
set encoding=utf-8              " Set default encoding to UTF-8
set autowrite                   " Automatically save before :next, :make etc.
set autoread                    " Automatically reread changed files without asking me anything
set laststatus=2
set hidden

syntax sync minlines=256
set synmaxcol=300

" Enable folding
set foldmethod=indent
set foldlevel=99

"set re=1
"set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
set statusline=%<[%n]\ %F\ %m%r%y\ %{exists('g:loaded_fugitive')?fugitive#statusline():''}\ %=%-14.(%l,%c%V%)\ %P

set fileformats=unix,dos,mac    " Prefer Unix over Windows over OS 9 formats

"http://stackoverflow.com/questions/20186975/vim-mac-how-to-copy-to-clipboard-without-pbcopy
set clipboard=unnamed

" Better Completion
" set complete-=i
set complete=.,w,b,u,t
set completeopt=longest,menuone

" Wildmeu completion {{{
set wildmenu
set wildmode=list:full

set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.spl                            " compiled spelling word lists
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store                       " OSX bullshit
set wildignore+=*.luac                           " Lua byte code
set wildignore+=migrations                       " Django migrations
set wildignore+=go/pkg                           " Go static files
set wildignore+=go/bin                           " Go bin files
set wildignore+=go/bin-vagrant                   " Go bin-vagrant files
set wildignore+=*.pyc                            " Python byte code
set wildignore+=*.orig                           " Merge resolution files

set ofu=syntaxcomplete#Complete                  "Set omni-completion method.
set report=0    "Show all changes

" https://github.com/junegunn/fzf
set rtp+=~/.fzf

" Enabling neocomplete at startup
let g:neocomplete#enable_at_startup = 1

" Use smartcase
let g:neocomplete#enable_smart_case = 1

" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3

" ==================== YouCompleteMe ====================
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_min_num_of_chars_for_completion = 1
map <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>

" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

let g:airline_theme='powerlineish'

" Change leader to ','
let mapleader=","

let jshint2_read = 1

let jshint2_save = 1

" ==================== FZF =========================
nnoremap <Leader>f :FZF<CR>

" ==================== Fugitive ====================
nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gp :Gpush<CR>
nnoremap <leader>gc :Gcommit<CR>
vnoremap <leader>gb :Gblame<CR>

" Explore with NerdTree Style by default
let g:netrw_liststyle=3
