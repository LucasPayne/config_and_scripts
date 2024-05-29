#!/bin/bash
#
# Set up the configuration symlinks.
#
# todo:
#    Ask for confirmation if a file would be deleted.

ln -s -f "$(realpath vim/vimdir/)" ~/.vim
ln -s -f "$(realpath vim/vimrc.vim)" ~/.vimrc
ln -s -f "$(realpath bash/bashrc.sh)" ~/.bashrc
ln -s -f "$(realpath bash/bash_aliases.sh)" ~/.bash_aliases
ln -s -f "$(realpath bash/bash_profile.sh)" ~/.bash_profile
ln -s -f "$(realpath bash/bash_logout.sh)" ~/.bash_logout
ln -s -f "$(realpath gdb/gdbinit.gdb)" ~/.gdbinit
ln -s -f "$(realpath gdb/)" ~/.gdb
ln -s -f "$(realpath X/Xresources.txt)" ~/.Xresources
ln -s -f "$(realpath X/xinitrc)" ~/.xinitrc
ln -s -f "$(realpath X/xsession)" ~/.xsession
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
ln -s -f "$(realpath freedesktop.org/autostart)" ~/.config/autostart
ln -s -f "$(realpath cool-retro-term)" ~/.local/share/cool-retro-term

# ~/.local/share/applications.
# The system saves files in here, so don't want to copy those to this repo.
# Currently can't think of a nice symlink-overlay solution. Possible?
# overlayfs possibly, but way too much to do for such a simple thing. Also I think this supposes read-only for underlying directory.
cp freedesktop.org/user_applications_overrides/*.desktop ~/.local/share/applications
