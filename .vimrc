set nocompatible    "Behave like vime and not like vi! (Much, much better)
syntax on

set 
utoindent      "alwasy set autoindenting on
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
set number      "Add line numbers
set ruler       "Display Cursor Position
set title       "Display filename in titlebar
set titleold=   "Prevent the "Thanks for flying Vim"
set hlsearch    "Highlight search

" Search options
set incsearch   "Display search resultings as you type
set ignorecase
set smartcase
" ------------------
set mouse=a;    "Enable mouse in all modes
set wildmenu

set backspace=indent,eol,start
set history=100
set ruler

set showcmd
set showmode    "Show the current mode
set complete-=i
set wildmenu

set ofu=syntaxcomplete#Complete "Set omni-completion method.
set report=0    "Show all changes

