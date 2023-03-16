#!/bin/bash
#
# Set up the configuration symlinks.
#
# todo:
#    Ask for confirmation if a file would be deleted.

ln -s -f "$(realpath vim/vimdir/)" ~/.vim
ln -s -f "$(realpath vim/vimrc.vim)" ~/.vimrc
ln -s -f "$(realpath bash/bashrc.sh)" ~/.bashrc
ln -s -f "$(realpath X/Xresources.txt)" ~/.Xresources
ln -s -f "$(realpath screen/screenrc.txt)" ~/.screenrc
ln -s -f "$(realpath readline/inputrc.txt)" ~/.inputrc
ln -s -f "$(realpath pager/lesskey.txt)" ~/.lesskey
ln -s -f "$(realpath i3)" ~/.i3
