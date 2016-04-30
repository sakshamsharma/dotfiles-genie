source ~/.vim/vimfiles/plugins.vim
source ~/.vim/vimfiles/functions.vim
source ~/.vim/vimfiles/keys.vim
source ~/.vim/vimfiles/settings.vim
source ~/.vim/vimfiles/appearance.vim
source ~/.vim/vimfiles/haskell.vim
source ~/.vim/vimfiles/completions.vim

" Syntax checking make plugin
if has('nvim')
  source ~/.vim/vimfiles/neomake.vim
else
  source ~/.vim/vimfiles/syntastic.vim
endif

" TODO
" Move these commands into their proper places (?) sometime

" For LaTeX-Suite
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'

" Ignore gitignored files in ctrlp output
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif  "To autoclose if only nerd left

" Tabularize
vmap a= :Tabularize /=<CR>
vmap a; :Tabularize /::<CR>
vmap a- :Tabularize /-><CR>

" Miscellaneous
" ===============
" ===============

" The following content taken from Harsh Sharma's vimrc

" To toggle line numbering
noremap <F4> :set invnu invrnu<CR>

" Switch between different tab widths
nnoremap <Leader>2 :set sw=2 <Bar> set sts=2<CR>
nnoremap <Leader>4 :set sw=4 <Bar> set sts=4<CR>

" capitalize the word preceding the cursor in insert mode
imap <C-C> <Esc>gUiw`]a

map <F8> :noremap j 3j <CR> :noremap k 3k <CR>
map <S-F8> :noremap j j <CR> :noremap k k <CR>


" Notes
" ===============
"
" For syntastic
" ===
"
" C/C++   ==> Install gcc
" CSS     ==> sudo npm install -g csslint
" Dart    ==> dartanalyzer (comes with dart)
" JS/HTML ==> sudo npm install -g jshint
" JSON    ==> sudo npm install -g jsonlint
"
" For haskell
" ===
" Install ghc-mod, hsdevtools
