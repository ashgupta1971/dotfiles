" .vimrc
" Author: Ashish Gupta
" Date: Apr 7 2017 Initial implementation.

"
" Enable blowfish2 encryption
"
set cm=blowfish2

"
" Abbreviations
"
:ab sig YOUR NAME GOES HERE

"
" Key bindings
"
:map <F4> i<h1><Esc>ea</h1><Esc>a
let mapleader=","       " leader is comma
" edit vimrc/zshrc and load vimrc bindings
nnoremap <leader>ev :vsp ~/.vimrc<CR>
nnoremap <leader>ez :vsp ~/.zshrc<CR>
nnoremap <leader>sv :source ~/.vimrc<CR>
" save session
nnoremap <leader>s :mksession<CR>

"
" Line numbering
"
set number
set relativenumber

"
" Colors and syntax highlighting
"
color darkblue
syntax enable

"
" Tabs and spaces
"
set tabstop=4	" number of visual spaces per tab
set softtabstop=4	" number of spaces in tab when editing
set expandtab	" tabs are spaces

"
" Misc settings 
"
set showcmd     " show command in bottom bar
set cursorline          " highlight current line
filetype indent on      " load filetype-specific indent files
set wildmenu            " visual autocomplete for command menu
set lazyredraw          " redraw only when we need to
set showmatch           " highlight matching [{()}]
" set colorcolumn=80    " highlight column 80

"
" Searching
"
set ignorecase
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
" turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>

"
" Folding (hiding blocks of text)
"
"set foldenable          " enable folding
"set foldlevelstart=0   " open most folds by default, 0=all block hidden, 99=all blocks open
"set foldnestmax=10      " 10 nested fold max
" space open/closes folds
"nnoremap <space> za
"set foldmethod=indent   " fold based on indent level
