map <Leader>s :SyntasticToggleMode<CR>

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1

let g:syntastic_cpp_compiler_options = '-std=c++14'

autocmd FileType javascript let g:syntastic_javascript_checkers = ['eslint']

autocmd FileType python let g:syntastic_python_checkers = ['pylint']
