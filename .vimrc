" Type :so % to refresh .vimrc after making changes -> Thanks to https://github.com/colbycheeze/dotfiles/blob/master/vimrc
"Behave like vim and not like vi! (Much, much better)
set nocompatible    
set background=dark

colorscheme hybrid

" Change leader to ','
let mapleader=","

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

" Lang "
Plug 'fatih/vim-go'
Plug 'nsf/gocode'
"Plug 'Shougo/vimproc.vim'
Plug 'Shougo/unite.vim'
Plug 'garyburd/go-explorer'
" Python
Plug 'scrooloose/syntastic', { 'for' : 'python' }
Plug 'nvie/vim-flake8'

" Web Development
Plug 'othree/html5.vim', {'for': 'html'}
Plug 'mattn/emmet-vim', { 'for' : ['html', 'css'] }
Plug 'skammer/vim-css-color', {'for': 'css'}
Plug 'Shutnik/jshint2.vim'
Plug 'groenewege/vim-less'
"Plug 'pangloss/vim-javascript', {'for': 'javascript'}
Plug 'jelera/vim-javascript-syntax', {'for': 'javascript'}
Plug 'nono/jquery.vim', {'for': 'javascript' }
Plug 'kchmck/vim-coffee-script'
Plug 'elzr/vim-json', {'for' : 'json'}
Plug 'digitaltoad/vim-jade', {'for': 'jade'}
Plug 'jaxbot/browserlink.vim'

" Misc
Plug 'easymotion/vim-easymotion'
Plug 'bling/vim-airline'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install --all' }
Plug 'tpope/vim-surround'
Plug 'mileszs/ack.vim'
Plug 'junegunn/vim-pseudocl'
Plug 'junegunn/vim-oblique'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

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
	"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
	autocmd Filetype python call SetPythonOptions()
	autocmd BufWritePost *.js silent :JSHint
endif

" File Type settings
au BufNewFile,Bufread *.vim setlocal noet ts=4 sw=4 sts=4
au BufNewFile,Bufread *.txt setlocal noet ts=4 sw=4
au BufNewFile,Bufread *.md setlocal noet ts=4 sw=4

" Go settings
au BufNewFile,Bufread *.go setlocal noet ts=4 sw=4 sts=4

" coffeescript settings
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

let python_highlight_all=1

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
" node run files
autocmd filetype javascript nnoremap <Leader>c :w <CR>:!node %<CR>

set autoindent      "alwasy set autoindenting on
set smartindent

" HTML Editing
set matchpairs+=<:>

"Toggle relative numbering, and set to absolute on loss of focus or insert mode
set rnu

function! ToggleNumbersOn()
    set nu!
    set rnu
endfunction

function! ToggleRelativeOn()
    set rnu!
    set nu
endfunction

autocmd FocusLost * call ToggleRelativeOn()
autocmd FocusGained * call ToggleRelativeOn()
autocmd InsertEnter * call ToggleRelativeOn()
autocmd InsertLeave * call ToggleRelativeOn()

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Use tab to jump between blocks, because it's easier
nnoremap <tab> %
vnoremap <tab> %

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Quickly close windows
nnoremap <leader>x :x<cr>
nnoremap <leader>X :q!<cr>

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
set numberwidth=2
" Make it obvious where 80 characters is
set textwidth=80

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

" ==================== NERDTree Options =================
let NERDTreeIgnore=['CVS','\.dSYM$', '.git', '.DS_Store', '*.swp', '*.swo', '*.swo']

" setting root dir in NT also sets VIM's cd
let NERDTreeChDirMode=2

" For toggling
"noremap <Leader>n :<C-u>call g:NerdTreeFindToggle()<cr>
map <C-z> :NERDTree<CR>
map <C-c> :NERDTreeToggle<CR>

" These prevent accidentally loading files while focused on NERDTree
autocmd FileType nerdtree noremap <buffer> <c-left> <nop>
autocmd FileType nerdtree noremap <buffer> <c-h> <nop>
autocmd FileType nerdtree noremap <buffer> <c-right> <nop>
autocmd FileType nerdtree noremap <buffer> <c-l> <nop>

" Open NERDTree if we're executing vim without specifying a file to open
autocmd vimenter * if !argc() | NERDTree | endif

" Hides "Press ? for help"
let NERDTreeMinimalUI=1

" Shows invisibles
let g:NERDTreeShowHidden=1

" ==================== Vim-go ====================
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

map <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>

" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

let g:airline_theme='powerlineish'
let g:airline_powerline_fonts = 1

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

function! s:tag_line_handler(l)
    let keys = split(a:l, '\t')
    exec 'tag' keys[1]
endfunction

function! MakeTags()
    echo 'Preparing tags...'
    call system('ctags -R')
    echo 'Tags done'
endfunction

let php_sql_query=1
let php_htmlInStrings=1
let g:rooter_use_lcd=1

" Explore with NerdTree Style by default
let g:netrw_liststyle=3

" Resize splits when the window is resized
au VimResized * :wincmd =

" update dir to current file
autocmd BufEnter * silent! cd %:p:h

" Typos since I suck @ typing
command! -bang E e<bang>
command! -bang Q q<bang>
command! -bang W w<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Wq wq<bang>
command! -bang WQ wq<bang>