"
"
"
"

" Settings
"    syntax on
"    ...
"<<<
syntax on
filetype plugin indent on
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
" set autochdir
set foldmethod=marker
set foldmarker=<<<,>>>
" set cursorline
set number
set nuw=5
set noswapfile
set mouse=a
">>>

" Basic mappings
"     inoremap jk <esc>
"     ...
"<<<
inoremap jk <esc>
nnoremap Q @q
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L $
onoremap H ^
onoremap L $
nnoremap .ev :edit ~/.vimrc<cr>
nnoremap .sv :source ~/.vimrc<cr>
inoremap <tab> <space><space><space><space>
nnoremap gj gT
nnoremap gk gt
">>>

" Plugins
"    execute pathogen#infect()
"    ...
"<<<
execute pathogen#infect()
function! PluginEnabled(plugin_name)
    let l:path = expand("~")."/.vim/bundle/".a:plugin_name
    return filereadable(l:path) || isdirectory(l:path)
endfunction

if PluginEnabled("vim-surround")
    nmap s ys
endif

if PluginEnabled("tagbar")
    nnoremap <leader>T :Tagbar<cr>
endif
">>>

" Source the syncer'd mappings.
source ~/code/syncer/syncer-vim.vim
