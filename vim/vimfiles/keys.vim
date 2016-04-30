" Save with root priviledges
cmap w!! w !sudo tee % >/dev/null

" Return in normal mode inserts new line
" Shift+Return inserts new line at top
nmap <S-Enter> O<Esc> nmap <CR> o<Esc>

" Toggles paste mode
set pastetoggle=<F2>

" New cool space mappings
nnoremap <Space>w :w<CR>
nnoremap <Space>q :x<CR>
vmap <Space>y "+yy
vmap <Space>d "+dd
nmap <Space>y "+yy
nmap <Space>d "+dd
nmap <Space>p "+p
nmap <Space>P "+P
vmap <Space>p "+p
vmap <Space>P "+P

" Allows going down in the wrapped portion of a line
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

" reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" Make new windows with <ctrl>+w + v , <ctrl>+w + s and close with <ctrl>+w+q
nmap <c-j> <c-w>j
nmap <c-k> <c-w>k
nmap <c-l> <c-w>l
nmap <c-h> <c-w>h

" Compile LaTeX
"nmap <F5> :w !pdflatex %<return> :!zathura %:r.pdf&<return><return>
nmap <F5> ;w !pdflatex %<return>

nmap <Space> i_<Esc>r

" map : to ; and vice-versa
" so you don't have to hold down shift to get into command mode
nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;

" repeat last defined macro, Bonus: no Ex mode
nnoremap Q @@

" For camelcasemotion
" Useful to remember
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
sunmap w
sunmap b
sunmap e

" Exceptionally useful, these both
" NERDcommenter mapping
nmap // <leader>ci

" EasyMotion
nmap .. <leader><leader>w
nmap ,, <leader><leader>b

" CtrlP
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

" NERDTree open
nmap <F3> ;NERDTreeToggle<return>

nmap <F7> ;TagbarToggle<CR>


" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

if has('nvim')
  tnoremap <C-t> <C-\><C-n>
  tnoremap <Esc> <C-\><C-n>
  nmap <BS> <C-W>h
endif
