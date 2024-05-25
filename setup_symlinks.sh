#!/bin/bash
#
# Set up the configuration symlinks.
#
# todo:
#    Ask for confirmation if a file would be deleted.

ln -s -f "$(realpath vim/vimdir/)" ~/.vim
ln -s -f "$(realpath vim/vimrc.vim)" ~/.vimrc
ln -s -f "$(realpath bash/bashrc.sh)" ~/.bashrc
ln -s -f "$(realpath bash/bash_profile.sh)" ~/.bash_profile
ln -s -f "$(realpath gdb/gdbinit.gdb)" ~/.gdbinit
ln -s -f "$(realpath gdb/)" ~/.gdb
ln -s -f "$(realpath X/Xresources.txt)" ~/.Xresources
ln -s -f "$(realpath X/xinitrc)" ~/.xinitrc
ln -s -f "$(realpath screen/screenrc.txt)" ~/.screenrc
ln -s -f "$(realpath readline/inputrc.txt)" ~/.inputrc
ln -s -f "$(realpath pager/lesskey.txt)" ~/.lesskey
ln -s -f "$(realpath git/gitconfig)" ~/.gitconfig
ln -s -f "$(realpath git/tigrc)" ~/.tigrc
ln -s -f "$(realpath i3)" ~/.i3
ln -s -f "$(realpath scripts)" ~/scripts
ln -s -f "$(realpath source-highlight)" ~/.source-highlight
ln -s -f "$(realpath lf)" ~/.config/lf
ln -s -f "$(realpath qutebrowser)" ~/.config/qutebrowser
ln -s -f "$(realpath nvim)" ~/.config/nvim
ln -s -f "$(realpath apt/dpkg.cfg)" ~/.dpkg.cfg
