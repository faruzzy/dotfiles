set nocompatible    "Behave like vim and not like vi! (Much, much better)
colorscheme hybrid
set background=dark
syntax on

execute pathogen#infect()

if has("autocmd")
    " Enable file type detection
    filetype on                  
    filetype plugin indent on    
    " Treat .json files as .js
    autocmd BufNewFile,Bufread *.json setfiletype json syntax=javascript
    " Treat .md files as Markdown
    autocmd BufNewFile,Bufread *.md setlocal filetype=markdown
endif

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
"hi CursorLine term=none ctermbg=darkblue ctermfg=white
"hi CursorLine term=none ctermbg=LightBlue ctermfg=white
hi CursorLine term=none ctermbg=205 ctermfg=white 

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
set paste

set wildmenu

set backspace=indent,eol,start
set history=100

" Settings

"No beeps
set noerrorbells	"No beeps 

"Add line numbbbers
set number      

"Show me what I'm typing
set showcmd	    

"Show the current mode
set showmode    

set noswapfile                  " No beeps
set nobackup                    " Don't create annoying backup files
set encoding=utf-8              " Set default encoding to UTF-8
set autowrite                   " Automatically save before :next, :make etc.
set autoread                    " Automatically reread changed files without asking me anything
set laststatus=2
set hidden

syntax sync minlines=256
set synmaxcol=300
"set re=1
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

set fileformats=unix,dos,mac    " Prefer Unix over Windows over OS 9 formats

"http://stackoverflow.com/questions/20186975/vim-mac-how-to-copy-to-clipboard-without-pbcopy
set clipboard^=unnamed
set clipboard^=unnamedplus

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

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
