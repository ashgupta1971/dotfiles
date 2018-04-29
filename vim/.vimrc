" .vimrc
" Author: Ashish Gupta
" Date: Apr 7 2017 Initial implementation.
"       Dec 20 2017 More changes as suggested by Fuzicast.

"
" Enable plugins
"
filetype plugin on

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
:map <F2> :tabnew<CR>
:map <F3> gt
:map <F4> :tabclose<CR>
:map <F5> :qa<CR>

" Open file whose name is currently under cursor in a new tab
:map <F6> <C-W>gf<CR> 

" Open file browser
:map <F7> :tabnew<CR>:Explore<CR>

" Dummy map
:map <F8> <h1><Esc>ea</h1><Esc>a

let mapleader=","       " leader is comma
" edit vimrc/zshrc and load vimrc bindings
nnoremap <leader>ev :vsp ~/.vimrc<CR>
nnoremap <leader>ez :vsp ~/.zshrc<CR>
nnoremap <leader>sv :source ~/.vimrc<CR>
" save session
nnoremap <leader>s :mksession<CR>

" Make sure Vim returns to the same line when you reopen a file.
" Thanks, Amit
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

"
" Display file name in title bar
"
set title

"
" Allow mouse to move cursor
"
set mouse=a

"
" Allow tab completion of commands
"
set wildmenu

"
" Better handling of tabs when pasting
"
set paste

"
" Line numbering
"
set number
set relativenumber

"
" Don't hit edge of screen when scrolling
"
set scrolloff=5

"
" Colors and syntax highlighting
"
color ron
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
