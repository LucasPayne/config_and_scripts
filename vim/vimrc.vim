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
" Disable splash
set shm+=I
set ignorecase
set smartcase
" set showtabline=2
set showtabline=1
set splitright
">>>

" Basic mappings
"    inoremap jk <esc>
"    ...
"<<<
inoremap jk <esc>
let mapleader = "."
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

if PluginEnabled("vim-surround") == 1
    nmap s ys
endif

if PluginEnabled("tagbar") == 1
    nnoremap <leader>T :Tagbar<cr>
endif
">>>

" Colors and syntax highlighting
"    set colorscheme ...
"    ...
"<<<
colorscheme solarized
set background=dark
">>>


" Vim server
" ...
"<<<
nnoremap <C-z> :call SuspendNoVimDir()<cr>
" Suspend and save vimdir so bash scripts can cd to it.
nnoremap <leader>z :call SuspendNoVimDir()<cr>
nnoremap <leader>Z :call Suspend()<cr>
nnoremap <leader>Z :call Suspend()<cr>
" Alt-q is much easier to press. Also can bind Alt-q to re-open vim session in readline.
execute "set <M-q>=\eq"
nnoremap <M-q> :call SuspendNoVimDir()<cr>

function! Suspend()
    call SaveDir()
    suspend
endfunction
function! SaveDir()
    silent! execute "!echo \"".expand("%:p:h")."\" > /tmp/vimdir"
endfunction

function! SuspendNoVimDir()
    silent! execute "!rm /tmp/vimdir"
    suspend
endfunction

autocmd VimLeave * :!echo "1" > /tmp/${VIM_SERVER_ID}_vim_server_closed
">>>



" Source the syncer'd mappings.
source ~/code/syncer/syncer-vim.vim
