"
"                                                       ▟▙
"                                                       ▝▘
"               ██▃▅▇█▆▖  ▗▟████▙▖   ▄████▄     ██▄  ▄██  ██  ▗▟█▆▄▄▆█▙▖
"               ██▛▔ ▝██  ██▄▄▄▄██  ██▛▔▔▜██    ▝██  ██▘  ██  ██▛▜██▛▜██
"               ██    ██  ██▀▀▀▀▀▘  ██▖  ▗██  █  ▜█▙▟█▛   ██  ██  ██  ██
"               ██    ██  ▜█▙▄▄▄▟▊  ▀██▙▟██▀     ▝████▘   ██  ██  ██  ██
"               ▀▀    ▀▀   ▝▀▀▀▀▀     ▀▀▀▀         ▀▀     ▀▀  ▀▀  ▀▀  ▀▀
""

" House keeping {{{
filetype plugin indent on														  " Enable file type detection
syntax on																  " Syntax highlighting
syntax sync minlines=256
let mapleader=","															  " Change leader to ','
let s:darwin = has('mac')
" }}}

set number relativenumber														  " The current line number is always show in the left gutter, along with the relative line numbers above/below
set cmdheight=2																  " Give more space for display messages
set noshowmode																  " Don't Show the current mode Since we're using airline
set signcolumn=yes
set updatetime=300
set title																  " Display filename in titlebar
set titleold=																  " Prevent the 'Thanks for flying Vim'
set ttyfast																  " Optimize for fast terminal connections
set lazyredraw																  " Wait to redraw, do not redraw while executing macros
set nowrap
set fo+=o																  " Automatically insert the current comment leader after hitting 'o' or 'O' in Normal mode.
set fo-=r																  " Do not automatically insert a comment leader after an enter
set fo-=t																  " Do not auto-wrap text using textwidth (does not apply to comments)
set linebreak
set dictionary+=/usr/share/dict/words
set spelllang=en_us,fr															  " Spell checking language
set display=lastline

set diffopt=filler															  " Add vertical spaces to keep right and left aligned
set diffopt+=vertical															  " make :diffsplit default to vertical
set shell=/bin/sh															  " Use /bin/sh for executing shell commands
set timeoutlen=1250															  " Reduce annoying delay for key codes, especially <Esc>...
set formatoptions+=1

" Encoding {{{

set encoding=utf-8
set fileencodings=utf-8,cp932,euc-jp													  " A list of character encodings, set default encoding to UTF-8
set guifont=Fira\ Code\ Retina:h13
scriptencoding utf8															  " utf-8 all the way
if !has('nvim')
  set term=xterm-256color
endif

if has('nvim') || has('termguicolors')
  "set termguicolors
endif

set t_ut=																  " Disable background color erase, play nicely with tmux
set fileformats=unix,dos,mac														  " Prefer Unix over Windows over OS 9 formats

" }}}

" Identation Settings {{{

set autoindent																  " Always set autoindenting on
set smartindent
set cindent
set indentkeys-=0#															" Do not break indent on #
set cinkeys-=0#
set expandtab																" Use the appropriate number of spaces to insert a <Tab>b
set shiftround																" Round indent to multiple of 'shiftwidth
set shiftwidth=2															" Number of spaces to use for each step of (auto)indent
set softtabstop=2															" Number of spaces that a <Tab> in the file counts for
set smarttab																" At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shifwidth spaces.
set backspace=indent,eol,start

" }}}

" Search Basic Settings {{{

set incsearch																" Display search resultings as you type
set hlsearch | nohlsearch														" Highlight search, support reloading
set ignorecase																" Ignore case in search patterns
set smartcase																" Override the ignorecase option if the pattern contains upper case
set gdefault																" By default add g flag to search/replace. Add g to toggle

" }}}

set matchpairs+=<:>															" For HTML Editing
set matchtime=2																" Bracket blinking
set splitright																" By default, (horizontal) split to the right
set splitbelow																" By default, (vertical) split to the bottom
set binary																" Don't add empty new lines at the end of files
set noeol
set cursorline																" Highlight current line
set nocursorcolumn

if has('mouse')
  set mouse=a																" Enable mouse in all modes
endif

set mousemodel=popup
set path=$PWD/**															" You need this (trust me) to move around
set wildmenu
set history=1024															" Amount of Command history increased from default 20 to 1024
set noerrorbells visualbell t_vb=													" No beeps
set numberwidth=4															" Minimal number of columns to use for the line number
set scrolloff=5

" Turn Off Swap Files {{{

set noswapfile																" No beeps
set nobackup																" Don't create annoying backup files
set nowritebackup
set nowb

" }}}

set autowrite																" Automatically save before :next, :make etc.
set autoread																" Automatically reread changed files (outside of vim) without asking me anything
set laststatus=2															" Always show status line
set shortmess=atI															" shortens messages
set showcmd																" Show me what I'm typing
set hidden																" Display another buffer when current buffer isn't saved
set synmaxcol=300
set foldmethod=indent															" Enable folding
set foldlevel=99

" Modified from http://dhruvasagar.com/2013/03/28/vim-better-foldtext
function! NeatFoldText()
  let indent_level = indent(v:foldstart)
  let indent = repeat(' ',indent_level)
  let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
  let lines_count = v:foldend - v:foldstart + 1
  let lines_count_text = '-' . printf("%10s", lines_count . ' lines') . ' '
  let foldchar = matchstr(&fillchars, 'fold:\zs.')
  let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
  let foldtextend = lines_count_text . repeat(foldchar, 8)
  let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
  return indent . foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction
set foldtext=NeatFoldText()

"http://stackoverflow.com/questions/20186975/vim-mac-how-to-copy-to-clipboard-without-pbcopy
set clipboard^=unnamed,unnamed													" Use same clipbaord as macOS/Linux
set complete=.,w,b,u,t														" Better Completion
set completeopt=longest,menuone
set ofu=syntaxcomplete#Complete													" Set omni-completion method.
set report=0															" Show all changes

" ----------------------------------------------------------------------------
" Wildmenu completion {{{
" ----------------------------------------------------------------------------

set wildmenu														        " Command line autocompletion
set wildmode=list:full														" Shows all the options
set wildignore+=.hg,.git,.svn													" Version control
set wildignore+=*.aux,*.out,*.toc												" LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg											" binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest										" compiled object files
set wildignore+=*.spl														" compiled spelling word lists
set wildignore+=*.sw?														" Vim swap files
set wildignore+=*.bak,*.?~,*.??~,*.???~,*.~											" Backup files
set wildignore+=*.DS_Store													" OSX bullshit
set wildignore+=*.luac														" Lua byte code
set wildignore+=migrations													" Django migrations
set wildignore+=go/pkg														" Go static files
set wildignore+=go/bin														" Go bin files
set wildignore+=go/bin-vagrant													" Go bin-vagrant files
set wildignore+=*.pyc														" Python byte code
set wildignore+=*.jar														" Java archives
set wildignore+=*.orig														" Merge resolution files
set wildignore+=*.stats														" Merge resolution files
set wildignore+=**/node_modules/**
set wildignore+=**/cache/**
set wildignore+=**/logs/**
set wildignore+=**/cov/**
set wildignore+=**/vendor/**
set wildignore+=**/bower_components/**

" }}}

" ----------------------------------------------------------------------------
" Plug begins {{{
" ----------------------------------------------------------------------------

call plug#begin('~/.config/plugged')

" Git {{{

Plug 'tpope/vim-fugitive'													" Git wrapper
Plug 'tpope/vim-rhubarb'													" GitHub extension for fugitive
Plug 'junegunn/gv.vim', { 'on': 'GV' }												" A git commint browser
Plug 'stsewd/fzf-checkout.vim'
let g:fzf_checkout_git_options = '--sort=-committerdate'
let g:fzf_branch_actions = {
\ 'track': {'keymap': 'ctrl-t'},
\}
if exists('$TMUX')
  let g:fzf_layout = { 'tmux': '-p90%,60%' }
else
  let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
endif

let $FZF_DEFAULT_OPTS .= ' --inline-info'

let g:fzf_colors =
\ { 'fg':         ['fg', 'Normal'],
\ 'bg':         ['bg', 'Normal'],
\ 'preview-bg': ['bg', 'NormalFloat'],
\ 'hl':         ['fg', 'Comment'],
\ 'fg+':        ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
\ 'bg+':        ['bg', 'CursorLine', 'CursorColumn'],
\ 'hl+':        ['fg', 'Statement'],
\ 'info':       ['fg', 'PreProc'],
\ 'border':     ['fg', 'Ignore'],
\ 'prompt':     ['fg', 'Conditional'],
\ 'pointer':    ['fg', 'Exception'],
\ 'marker':     ['fg', 'Keyword'],
\ 'spinner':    ['fg', 'Label'],
\ 'header':     ['fg', 'Comment'] }

if v:version >= 703
	Plug 'mhinz/vim-signify'
elseif
	Plug 'airblade/vim-gitgutter'
endif

" }}}

" Color Schemes {{{

Plug 'junegunn/seoul256.vim'
Plug 'projekt0n/github-nvim-theme'
Plug 'joshdick/onedark.vim'
Plug 'mhartington/oceanic-next'
Plug 'morhetz/gruvbox'

" }}}

" Programming {{

Plug 'Shougo/echodoc.vim'														" Display function signature
Plug 'dense-analysis/ale'														" Checks syntax in Vim asynchronously
Plug 'Shougo/unite.vim'															" Unite and create user interfaces
Plug 'tpope/vim-unimpaired'														" Pairs of handy bracket mappings

" }}

" Go {{{

Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'nsf/gocode'

" }}}

" Java {{{

Plug 'udalov/javap-vim'
Plug 'udalov/kotlin-vim'

" }}}

" Python {{{

Plug 'nvie/vim-flake8'

" }}}

" HTML {{{

Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'othree/html5-syntax.vim', { 'for': 'html' }
Plug 'gregsexton/MatchTag', { 'for': 'html' }															" highlight matching html tag
Plug 'tmhedberg/matchit', { 'for': 'html' }																" Extended % matching for HTML
Plug 'othree/xml.vim', { 'for': 'html' }																	" Helps editing [x]hml like files
Plug 'mustache/vim-mustache-handlebars', { 'for': 'hbs' }

Plug 'mattn/emmet-vim', { 'for' : ['html', 'css', 'javascript'] }					" Emmet for Vim
let g:user_emmet_jsx = 1
let g:user_emmet_settings = {
\ 'javascript' : { 'extends' : 'jsx' },
\ 'javascript.jsx' : { 'extends' : 'jsx', },
\ 'javascriptreact' : { 'extends' : 'jsx' },
\ 'typescript' : { 'extends' : 'jsx' },
\ 'typescript.jsx' : { 'extends' : 'jsx' },
\ 'typescript.tsx' : { 'extends' : 'jsx' },
\ 'typescriptreact' : { 'extends': 'jsx' },
\}

" }}}

" PHP {{{

Plug 'StanAngeloff/php.vim', { 'for': 'php' }										" PHP Syntax

" }}}


" ECMAScript {{{

" The next two plugins helps commenting react code out and works in
" conjunction with 'vim-commentary'
Plug 'MaxMEllon/vim-jsx-pretty'																						" Sets the value of ‘commentstring’ to a different value depending on the region of the file you are in.
Plug 'suy/vim-context-commentstring'																			" JSX syntax pretty highlighting for vim.
Plug 'HerringtonDarkholme/yats.vim'																				" Advanced TypeScript Syntax Highlighting
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = [
\ 'coc-tsserver',
\ 'coc-eslint',
\ 'coc-snippets',
\ 'coc-pairs',
\ 'coc-prettier',
\ 'coc-json',
\ 'coc-css',
\ 'coc-python',
\ 'coc-html',
\ 'coc-emmet',
\]

" show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<cr>

" goto type
nmap <silent> gk <Plug>(coc-type-definition)

" goto definition
nmap <silent> gd <Plug>(coc-definition)

" get references
nmap <silent> gr <Plug>(coc-references)

" format rename
nmap <silent> at <Plug>(coc-rename)

" format file
nmap <silent> fr <Plug>(coc-format)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

Plug 'othree/yajs', { 'for': 'javascript' }																" Yet Another JavaScript Syntax for Vim
Plug 'elzr/vim-json', { 'for' : 'json' }																	" json support

Plug 'SirVer/ultisnips'
Plug 'mlaursen/vim-react-snippets'

Plug 'pantharshit00/vim-prisma'
Plug 'jparise/vim-graphql'
let g:UltiSnipsExpandTrigger="<C-l>"
" }}}

" CSS {{{

Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }

" }}}

" Misc {{{

Plug 'wesQ3/vim-windowswap'													      " Allows you to swap windows easily without ruining your layout
Plug 'tpope/vim-commentary'																																											" Plugin that allows you to comment stuff out
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-vinegar'													      " netrw enhanced / alternative to NERDTree
Plug 'tpope/vim-sleuth'
Plug 'wellle/visual-split.vim'
Plug 'wincent/loupe'																																														" Enhanced in-file search for Vim
Plug 'jiangmiao/auto-pairs'																																											" provides insert mode auto-completion for quotes, parenthesis, brackets, etc
Plug 'easymotion/vim-easymotion'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }										      " fzf itself
Plug 'junegunn/fzf.vim'																																													" fuzzy search integration
Plug 'majutsushi/tagbar'																																												" Vim plugin that displays tags in a window, ordered by scop
Plug 'scrooloose/nerdtree'													      " A tree explorer plugin for vim.
Plug 'unkiwii/vim-nerdtree-sync'
" Plug 'Xuyuanp/nerdtree-git-plugin'												      " A plugin of NERDTree showing git status
Plug 'ryanoasis/vim-devicons'													      " Adds file type glyphs/icons to popular Vim plugins: NERDTree, vim-airline, Powerline, Unite, vim-startify and more
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }										      " Markdown Vim Mode
Plug 'sickill/vim-pasta'													      " Pasting in Vim with indentation adjusted to destination context TODO: check if I still need this
Plug 'jordwalke/VimSplitBalancer'												      " Distributes available space among vertical splits, and plays nice with NERDTree
"Plug 'dhruvasagar/vim-zoom' TODO: check if I still need this
Plug 'itspriddle/ZoomWin'													      " Zoom in and out of windows/buffer
Plug 'benmills/vimux'																																														" Easily interact with tmux from vim
Plug 'christoomey/vim-tmux-navigator'												      " Seamless navigation between tmux panes and vim splits
Plug 'tmux-plugins/vim-tmux-focus-events'											      " This plugin restores `FocusGained` and `FocusLost` when using vim inside Tmux.
Plug 'wellle/tmux-complete.vim'													      " adds a completion function that puts all words visible in your Tmux panes right under your fingertips
Plug 'psliwka/vim-smoothie'													      " makes scrolling nice and smooth every time you press Ctrl-D or Ctrl-F

" }}}

call plug#end()

" ----------------------------------------------------------------------------
" }}}
" ----------------------------------------------------------------------------

" colorscheme seoul256
" colorscheme gruvbox
colorscheme github_dark
"" ----------------------------------------------------------------------------
" fzf.vim {{{
" ----------------------------------------------------------------------------

" https://github.com/junegunn/fzf
set rtp+=~/.fzf

" Terminal buffer options for fzf
autocmd! FileType fzf
autocmd  FileType fzf set noshowmode noruler nonu

" ----------------------------------------------------------------------------
" }}}
" ----------------------------------------------------------------------------

" ----------------------------------------------------------------------------
" nnoremap {{{
" ----------------------------------------------------------------------------

" refresh current .vimrc file for change to take effect
nnoremap <leader>s :source %<cr>

nnoremap <C-p> :Root<cr>:Files<cr>

"show all opened buffers
nnoremap <Leader><Enter>	 :Buffers<CR>

nnoremap <silent> <leader>C	 :Colors<cr>
nnoremap <silent> <leader>l	 :Lines<cr>
nnoremap <silent> <leader>`	 :Marks<cr>

nnoremap <leader>dg :diffget<cr> :diffupdate<cr>
vnoremap <leader>dg :diffget<cr> :diffupdate<cr>

nnoremap <leader>dp :diffput<cr> :diffupdate<cr>
vnoremap <leader>dp :diffput<cr> :diffupdate<cr>

" Open the current directory in finder
nnoremap <leader>O :!open .<cr>

nnoremap <leader>o :only<cr>

" Deletes buffer without losing the split window
nnoremap <leader>bd :bp\|bd #<cr>

" Deletes all buffers except the current one
nnoremap <leader>ba :%bd\|e#\|bd#<cr>

" Search entire project
nnoremap <C-g> :RG<cr>
" Search word under the cursor globaly
nnoremap <C-s> :RT<cr>

" TODO: Find where this is coming from
"" nnoremap <C-g> :Rg<cr>

" npm install --save-dev word under cursor
nnoremap <leader>md :execute ":!npm install --save-dev " . expand("<cword>")<cr>

" npm install --save word under cursor
nnoremap <leader>m :execute ":!npm install --save " . expand("<cword>")<cr>

" Enable folding with the spacebar
nnoremap <space> za" Run python code by pressing F9

" Open new line below and above current line
nnoremap <leader>r o<esc>
nnoremap <leader>R O<esc>
" Better split switching (Ctrl-j, Ctrl-k, Ctrl-h, Ctrl-l) {{{

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" }}}

" Quick tab movement {{{

nnoremap tf :tabfirst<cr>
nnoremap tl :tablast<cr>
nnoremap ]t :tabnext<cr>
nnoremap [t :tabprev<cr>

" }}}

" Quick Buffers movement {{{

nnoremap ]b :bnext<cr>
nnoremap [b :bprev<cr>

" }}}

" move lines of text up or down {{{

nnoremap <C-J> :m .+1<cr>==
nnoremap <C-K> :m .-2<cr>==
inoremap <C-J> <Esc>:m .+1<cr>==gi
inoremap <C-K> <Esc>:m .-2<cr>==gi
vnoremap <C-J> :m '>+1<cr>gv=gv
vnoremap <C-K> :m '<-2<cr>gv=gv

" }}}

" Search and replace word under cursor (,*) {{{

nnoremap <leader>* :%s/\<<C-r><C-w>\>//<Left>
vnoremap <leader>* "hy:%s/\V<C-r>h//<left>

" }}}

nnoremap <F12> :exec ':silent !open -a /Applications/Google\ Chrome.app %'<cr>

" Use tab to jump between blocks, because it's easier
nnoremap <tab> %
vnoremap <tab> %

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Save and close current buffer
nnoremap <leader>x :wq!<cr>

" Save and close all buffer including those created by vimux (if any)
nnoremap <leader>X :call VimuxCloseRunner()<cr> :wqa!<cr>

" Close current buffer without saving
nnoremap <leader>q :q!<bR>

" Close all buffer without saving including those created by vimux (if any)
nnoremap <leader>Q :call VimuxCloseRunner()<cr> :qa!<cr>

" Quickly open .vimrc file in the current buffer
nnoremap <leader>v :e ~/Github/dotfiles/init.vim<cr>

" Quickly open .vimrc file in a new vertical buffer
nnoremap <leader>V :vs ~/Github/dotfiles/init.vim<cr>

nnoremap <leader>bg :GBranches<cr>

" Fugitive {{{

nnoremap <leader>ga :Git add %:p<cr><cr>
nnoremap <leader>gw :Gwrite<cr>
nnoremap <leader>gr :Gread<cr> :w<cr>
nnoremap <leader>gm :Gmove<cr>
nnoremap <leader>gy :Gremove<cr>
nnoremap <leader>gs :Git<cr>
nnoremap <leader>gp :Git push<cr>
nnoremap <leader>gl :Git pull<cr>
nnoremap <leader>gc :Git commit<cr>
nnoremap <leader>gd :NERDTreeClose<cr> :Gdiffsplit<cr>
nnoremap <leader>gb :Git blame<cr>
nnoremap <leader>gg :Gmerge<cr>
nnoremap <leader>gv :GV<cr>
nnoremap <leader>GV :GV!<cr>
nnoremap <leader>pp :Git push origin master<cr>

" }}}

" Plug {{{

nnoremap <leader>pi :PlugInstall<cr>
nnoremap <leader>pu :PlugUpdate<cr>
nnoremap <leader>pU :PlugUpgrade<cr>
nnoremap <leader>pc :PlugClean<cr>

" }}}

" ----------------------------------------------------------------------------
" }}}
" ----------------------------------------------------------------------------

let g:tmuxcomplete#trigger = 'omnifunc'

let g:ale_linters = {
\ 'python': ['flake8', 'pylint'],
\ 'javascript': ['eslint'],
\ 'vue': ['eslint']
\}

let g:ale_fixers = {
\ 'javascript': ['eslint'],
\ 'typescript': ['prettier', 'tslint', 'eslint'],
\ 'graphql': ['prettier', 'eslint'],
\ 'json': ['prettier', 'eslint'],
\ 'vue': ['eslint'],
\ 'scss': ['prettier'],
\ 'html': ['prettier'],
\ 'reason': ['refmt'],
\}

let g:ale_fix_on_save = 1

nnoremap ]r :ALENextWrap<cr>     " move to the next ALE warning / error
nnoremap [r :ALEPreviousWrap<cr> " move to the previous ALE warning / error

" ----------------------------------------------------------------------------
" autocmd {{{
" ----------------------------------------------------------------------------

augroup python3
	au! BufEnter *.py setlocal omnifunc=python3complete#Complete
augroup END

autocmd BufNewFile,Bufread *.json setfiletype json syntax=javascript								" Treat .json files as .js TODO: verify if this line works as intended considering the line below it lol
autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript
autocmd BufNewFile,BufRead *.tsx setlocal filetype=typescript.tsx
autocmd BufNewFile,BufRead *.jsx setfiletype=javascript.jsx

autocmd FileType css,sass,less set omnifunc=csscomplete#CompleteCSS
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType javascript let b:coc_root_patterns = ['.js', '.json']
autocmd FileType xml setlocal omnifunc=xmlComplete#CompleteTags
autocmd FileType python setlocal omnifunc=pythoncomplete#CompleteTags
autocmd FileType python let b:coc_root_patterns = ['.js', '.git', '.env']
autocmd Filetype python call SetPythonOptions()

autocmd BufNewFile,Bufread *.md setlocal filetype=markdown											" Treat .md files as Markdown
autocmd BufNewFile,Bufread *.js setlocal filetype=javascript

autocmd StdinReadPre * let s:std_in=1
autocmd GUIEnter * set visualbell t_vb=

autocmd CursorHold,CursorHoldI,FocusGained,BufEnter * checktime
autocmd FileChangedShellPost *
	\ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" Convenient mappings for compiling and running quick, used mostly for school
autocmd filetype c nnoremap <leader>c :w <cr>:!gcc % -o %:r && ./%:r<cr>
autocmd filetype java nnoremap <leader>c :w <cr>:!javac % && java %:r<cr>
autocmd filetype javascript nnoremap <leader>c :w <cr>:!node %<cr>
autocmd filetype sh nnoremap <leader>c :w <cr>:!bash %<cr>
autocmd filetype python nnoremap <leader>c :exec '!python' shellescape(@%, 1)<cr>

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

autocmd VimResized  * :wincmd =													      " Resize splits when the window is resized
autocmd BufEnter    * silent! cd %:p:h												      " update dir to current file

autocmd FileType go nmap <leader>s  <Plug>(go-def-split)
autocmd FileType go nmap <leader>v  <Plug>(go-def-vertical)
autocmd FileType go nmap <leader>in <Plug>(go-info)
autocmd FileType go nmap <leader>i  <Plug>(go-implements)
autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>g  <Plug>(go-gbbuild)
autocmd FileType go nmap <leader>t  <Plug>(go-test-compile)
autocmd FileType go nmap <leader>d  <Plug>(go-doc)
autocmd FileType go nmap <leader>f :GoImports<cr>

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

  " Automatically wrap at 80 characters and spell check git commit messages
  autocmd FileType gitcommit setlocal textwidth=80
  autocmd FileType gitcommit setlocal spell

  " Allow stylesheets to autocomplete hyphenated words
  autocmd FileType css,scss,sass,less setlocal iskeyword+=-
augroup END

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
  endif
augroup END

augroup airline_config
autocmd!
  let g:airline_theme='onedark'
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#buffer_nr_format = '%s '
  let g:airline#extensions#tabline#buffer_nr_show = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#fnamecollapse = 0
  let g:airline#extensions#tabline#fnamemod = ':t'
augroup END

" Cursorline {{{
" Only show cursorline in the current window and in normal mode.
augroup cline
  "TODO: does this work???
  nnoremap <silent> <expr> <leader><leader> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"

  autocmd!
  autocmd WinLeave,InsertEnter * set nocursorline
  autocmd  WinEnter,InsertLeave * set cursorline
augroup END

"" ----------------------------------------------------------------------------
" }}}
" ----------------------------------------------------------------------------

" python with virtualenv support
"py << EOF
"import os
"import sys
"if 'VIRTUAL_ENV' in os.environ:
"  project_base_dir = os.environ['VIRTUAL_ENV']
"  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
"  execfile(activate_this, dict(__file__=activate_this))
"EOF

let python_highlight_all=1

" tagbar installation, see:
" https://thomashunter.name/blog/installing-vim-tagbar-with-macvim-in-os-x
let g:tagbar_ctags_bin='/usr/local/bin/ctags' " Proper Ctags locations
let g:tagbar_width=26	" Default is 40, seems too wide
nmap <F8> :TagbarToggle<cr>

" }}}


" ----------------------------------------------------------------------------
" }}}
" ----------------------------------------------------------------------------

let g:nerdtree_sync_cursorline = 1

function! ToggleNerdTree()
  set eventignore=BufEnter
  NERDTreeToggle
  set eventignore=
endfunction

" ----------------------------------------------------------------------------
" Todo
" ----------------------------------------------------------------------------
function! s:todo() abort
  let entries = []
  for cmd in ['git grep -niI -e TODO -e FIXME -e XXX 2> /dev/null',
            \ 'grep -rniI -e TODO -e FIXME -e XXX * 2> /dev/null']
    let lines = split(system(cmd), '\n')
    if v:shell_error != 0 | continue | endif
    for line in lines
      let [fname, lno, text] = matchlist(line, '^\([^:]*\):\([^:]*\):\(.*\)')[1:3]
      call add(entries, { 'filename': fname, 'lnum': lno, 'text': text })
    endfor
    break
  endfor

  if !empty(entries)
    call setqflist(entries)
    copen
  endif
endfunction
command! Todo call s:todo()

nnoremap <C-c> :call ToggleNerdTree()<cr>
let NERDTreeChDirMode=2																			" setting root dir in NT also sets VIM's cd
let NERDTreeMapOpenSplit = "s"
let NERDTreeMapOpenVSplit = "v"
let NERDTreeMinimalUI = 1
let NERDTreeShowHidden = 1
let NERDTreeChristmasTree=1																		" Enable all colors for NERDTree
let NERDTreeDirArrows=1
let NERDTreeIgnore = ['\~$', '^\.git$', '^\.hg$', '^\.bundle$', '^\.jhw-cache$', '\.pyc$', '\.egg-info$', '__pycache__', '\.vagrant$', '\.dSYM$', '.DS_Store', '*.swp', '*.swo']

let g:netrw_liststyle=3																			" Explore with NerdTree Style by default
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

" }}}

" Close vim tmux runner opened by VimuxRunCommand
nnoremap <leader>vc :call VimuxCloseRunner()<cr>

" Run last command executed by VimuxRunCommand
nnoremap <leader>vl :VimuxRunLastCommand<cr>

" Interrupt any command that is running inside the runner pane
nnoremap <leader>vi :VimuxInterruptRunner<cr>

" Zoom the tmux runner page
nnoremap <leader>vz :VimuxZoomRunner<cr>

" Prompt for a command and run it in a small horizontal split bellow the current pane
nnoremap <leader>vr :Root<cr> :VimuxPromptCommand<cr>

nnoremap <leader>ys :Root<cr>:VimuxPromptCommand("yarn start")<cr><cr>
nnoremap <leader>yd :Root<cr>:VimuxPromptCommand("yarn dev")<cr><cr>
nnoremap <leader>yt :Root<cr>:VimuxPromptCommand("yarn test")<cr><cr>
nnoremap <leader>gt :Root<cr>:VimuxPromptCommand("yarn generate:types")<cr><cr>
"  }}}

" Vim-go {{{
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
" }}}

" Movement in insert mode {{{
inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>l
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
" }}}

" Hard to type things {{{
iabbrev >> →
iabbrev << ←
iabbrev ^^ ↑
iabbrev VV ↓
iabbrev aa λ
iabbrev @@ faruzzy@gmail.com
iabbrev ccopy Copyright 2018  Pangu, all rights reserved
" }}}

inoremap jk <esc>
inoremap <expr> <Tab> pumvisible() ? coc#_select_confirm() : "<Tab>"
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
nnoremap <leader>yfn  :CopyFilename<cr>
xnoremap <leader>yfn  :CopyFilename<cr>
nnoremap <leader>yp   :CopyPath<cr>
xnoremap <leader>yp   :CopyPath<cr>
nnoremap <leader>yap  :CopyAbsolutePath<cr>
xnoremap <leader>yap  :CopyAbsolutePath<cr>
nnoremap <leader>yfp  :CopyFilepath<cr>
xnoremap <leader>yfp  :CopyFilepath<cr>
nnoremap <leader>yafp :CopyAbsoluteFilepath<cr>
xnoremap <leader>yafp :CopyAbsoluteFilepath<cr>

" ----------------------------------------------------------------------------
" Custom functions {{{
" ----------------------------------------------------------------------------

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
nnoremap g<cr> :call FindALine()<cr>

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
nnoremap <silent> Q :call CloseWindowOrKillBuffer()<cr>

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --hidden --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let options = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command], 'dir': system('git -C '.expand('%:p:h').' rev-parse --show-toplevel 2> /dev/null')[:-2]}
  let options = fzf#vim#with_preview(options, 'right', 'ctrl-/')
  call fzf#vim#grep(initial_command, 1, options, a:fullscreen)
endfunction
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
command! -nargs=* -bang RT call RipgrepFzf(expand("<cWORD>"), <bang>0)

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
nmap <leader>w :StripTrailingWhitespaces<cr>:w<cr>

" Save a file as root (,W) and strip trailing white spaces
noremap <leader>W :StripTrailingWhitespaces<cr>:w !sudo tee % > /dev/null<cr>

" Exit the vimdiff buffer regardless of whether you're on the diff buffer or not
nnoremap <Leader>D <c-w>h<c-w>c

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
    echo 'Could not determine Git repo name for current file!'
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
nnoremap gx :call BrowserOpen()<cr>
xnoremap gx :call BrowserOpen()<cr>

function! s:tag_line_handler(l)
  let keys = split(a:l, '\t')
  exec 'tag' keys[1]
endfunction

"TODO: Do I need this?
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
nmap b<Tab> :call SwitchBuffer()<cr>

" Sets python options
function! SetPythonOptions()
  setlocal tabstop=4
  setlocal softtabstop=4
  setlocal shiftwidth=4
  setlocal smarttab
  setlocal expandtab
  setlocal autoindent
  set fileformat=unix
endfunction

" <leader>?/! | Google it / Feeling lucky
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

" ----------------------------------------------------------------------------
" Quickfix
" ----------------------------------------------------------------------------
nnoremap ]q :cnext<cr>zz
nnoremap [q :cprev<cr>zz
nnoremap ]l :lnext<cr>zz
nnoremap [l :lprev<cr>zz

" :Root | Change directory to the root of the Git repository
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

" Zoom
function! s:zoom()
  if winnr('$') > 1
    tab split
  elseif len(filter(map(range(tabpagenr('$')), 'tabpagebuflist(v:val + 1)'),
    \ 'index(v:val, '.bufnr('').') >= 0')) > 1
    tabclose
  endif
endfunction
nnoremap <silent> <leader>z :call <sid>zoom()<cr>

" ----------------------------------------------------------------------------
" }}}
" ----------------------------------------------------------------------------

" ************ Note to avoid headaches in the future *********************
" If you don't have python3 co plugins written in python 3 will not work
" Run `pip3 install pynvim`. It should install a Python provider
" ************************************************************************