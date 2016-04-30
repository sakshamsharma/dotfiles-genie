if has('nvim')
  let g:deoplete#enable_at_startup = 1
  let g:neocomplete#enable_at_startup = 0
  let g:acp_enableAtStartup = 0

  " deoplete-clang
  " libclang shared library path
  let g:deoplete#sources#clang#libclang_path = '/usr/lib/libclang.so'

  " clang builtin header path
  let g:deoplete#sources#clang#clang_header = '/usr/lib/clang'

  " C or C++ standard version
  let g:deoplete#sources#clang#std#c = 'c11'
  " or c++
  let g:deoplete#sources#clang#std#cpp = 'c++1z'

  " libclang complete result sort algorism
  " Default: '' -> deoplete.nvim delault sort order
  " libclang priority sort order
  let g:deoplete#sources#clang#sort_algo = 'priority'
  " alphabetical sort order
  let g:deoplete#sources#clang#sort_algo = 'alphabetical'

  " debug
  let g:deoplete#enable_debug = 1
  let g:deoplete#sources#clang#debug#log_file = '~/.log/nvim/python/deoplete-clang.log'

else
  source ~/.vim/vimfiles/neocomplete.vim
endif
