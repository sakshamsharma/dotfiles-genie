" Disable haskell-vim omnifunc
let g:haskellmode_completion_ghc = 0
autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

let g:haskell_tabular = 1

map <silent> tw :GhcModTypeInsert<CR>
map <silent> ts :GhcModSplitFunCase<CR>
map <silent> tq :GhcModType<CR>
map <silent> te :GhcModTypeClear<CR>

au FileType haskell nnoremap <buffer> <F1> :HdevtoolsType<CR>
au FileType haskell nnoremap <buffer> <silent> <F2> :HdevtoolsClear<CR>

autocmd BufWritePost *.hs :GhcModCheckAndLintAsync

function! s:add_xmonad_path()
  if !exists('b:ghcmod_ghc_options')
    let b:ghcmod_ghc_options = []
  endif
  call add(b:ghcmod_ghc_options, '--with-ghc `stack ghc`')
  call add(b:ghcmod_ghc_options, '-i' . expand('/home/saksham/.xmonad/lib'))
  call add(b:ghcmod_ghc_options, '-i' . expand('~/.cabal/lib/x86_64-linux-ghc-7.10.3/xmonad-0.12-GC8crqyzLJ3DdMXmSd6nek'))
  call add(b:ghcmod_ghc_options, '-i' . expand('~/.cabal/lib/x86_64-linux-ghc-7.10.3/xmonad-contrib-0.12-64SqU0zu0EKDNvkDrtHSCX'))
endfunction
autocmd BufRead,BufNewFile ~/.xmonad/* call s:add_xmonad_path()
autocmd BufRead,BufNewFile ~/.xmonad/lib/* call s:add_xmonad_path()

" Reload
map <silent> tu :call GHC_BrowseAll()<CR>

" For haskell
let g:haskell_enable_quantification = 1
let g:haskell_enable_recursivedo = 1
let g:haskell_enable_arrowsyntax = 1
let g:haskell_enable_pattern_synonyms = 1
let g:haskell_enable_typeroles = 1
let g:haskell_enable_static_pointers = 1
let g:haskell_indent_if = 3
