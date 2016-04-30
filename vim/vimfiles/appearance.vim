set t_Co=256
set background=dark
colorscheme jellybeans

set gfn=monofur\ for\ Powerline\ Regular\ 14

" For airline
if has('unix')
  set guifont=Liberation\ Mono\ for\ Powerline\ 14
  set laststatus=2
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#enabled = 1
endif

if has('unix')
  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif
endif
