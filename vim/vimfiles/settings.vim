"filetype plugin indent on
set wrap
set title  " Set window title automatically

set undofile
set undodir=~/.vim/undodir
set undolevels=1000

set foldmethod=indent   " Enable code folding with z,a
set foldlevel=99

set backspace=indent,eol,start
set shiftwidth=2
set shiftround
set tabstop=2
set smarttab
set expandtab
set wildmenu

set showmatch
set showcmd     "To show partial command in status bar
set nu        "For current line number
set rnu       "Relative numbering for the rest of the lines
set sidescroll=1

set ignorecase
set smartcase     "CSen only when capitals used.
set incsearch   "Starts showing results as you type
set hlsearch

set autoindent
set copyindent
set smartindent
set cindent

set history=1000
set scrolloff=6
set autoread    "Reloads file on change
set lazyredraw    " redraw only when we need to

set guioptions-=m
set guioptions-=T

" To avoid expanding tabs
autocmd Filetype make set noexpandtab

" To reset cursor position on reopening file
augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END


" Cursor shape tweaks
" Use bar in insert mode (much better than default one)
if has('nvim')
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
else
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[4 q"
  let &t_EI = "\<Esc>[2 q"
endif

if has('nvim')
  augroup term
    autocmd!
    autocmd BufWinEnter,WinEnter term://* setlocal nonumber norelativenumber
  augroup END
endif

" To use nasm mode for asm
au BufRead,BufNewFile *.asm set filetype=nasm

nnoremap <LEADER>f :call RunCtrlP()<CR>

fun! RunCtrlP()
  lcd %:p:h
  if (getcwd() == $HOME)
    echo "Can't run in \$HOME"
    return
  endif
  CtrlP
endfunc
