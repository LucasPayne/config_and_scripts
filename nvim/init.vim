" Transitioning from vim
" https://neovim.io/doc/user/nvim.html#nvim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
