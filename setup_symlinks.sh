#!/bin/bash
#
# Set up the configuration symlinks.
#
# todo:
#    Ask for confirmation if a file would be deleted.

# Setup symlinks on system to this config dir.
ln -n -s -f "$(realpath vim/runtime/)" ~/.vim
ln -n -s -f "$(realpath vim/vimrc.vim)" ~/.vimrc
ln -n -s -f "$(realpath emacs/infokey)" ~/.infokey
ln -n -s -f "$(realpath shell/profile.sh)" ~/.profile
ln -n -s -f "$(realpath shell/bashrc.sh)" ~/.bashrc
ln -n -s -f "$(realpath shell/bash_aliases.sh)" ~/.bash_aliases
ln -n -s -f "$(realpath shell/bash_profile.sh)" ~/.bash_profile
ln -n -s -f "$(realpath shell/bash_logout.sh)" ~/.bash_logout
ln -n -s -f "$(realpath gdb/gdbinit.gdb)" ~/.gdbinit
ln -n -s -f "$(realpath gdb/)" ~/.gdb
ln -n -s -f "$(realpath X/Xresources.txt)" ~/.Xresources
ln -n -s -f "$(realpath X/xinitrc)" ~/.xinitrc
ln -n -s -f "$(realpath X/xsession)" ~/.xsession
ln -n -s -f "$(realpath screen/screenrc.txt)" ~/.screenrc
ln -n -s -f "$(realpath screen/screendir)" ~/.screen
ln -n -s -f "$(realpath readline/inputrc.txt)" ~/.inputrc
ln -n -s -f "$(realpath pager/lesskey.txt)" ~/.lesskey
ln -n -s -f "$(realpath git/gitconfig)" ~/.gitconfig
ln -n -s -f "$(realpath git/tigrc)" ~/.tigrc
ln -n -s -f "$(realpath i3)" ~/.i3
ln -n -s -f "$(realpath scripts)" ~/scripts
ln -n -s -f "$(realpath source-highlight)" ~/.source-highlight
ln -n -s -f "$(realpath lf)" ~/.config/lf
ln -n -s -f "$(realpath qutebrowser)" ~/.config/qutebrowser
ln -n -s -f "$(realpath nvim)" ~/.config/nvim
ln -n -s -f "$(realpath apt/dpkg.cfg)" ~/.dpkg.cfg
ln -n -s -f "$(realpath freedesktop.org/autostart)" ~/.config/autostart
ln -n -s -f "$(realpath cool-retro-term/cool-retro-term-share)" ~/.local/share/cool-retro-term
ln -n -s -f "$(realpath cool-retro-term/cool-retro-term-config)" ~/.config/cool-retro-term

# Setup symlinks in this directory to system files.
# This is for convenient navigation of config. The directory contents, and the symlinks themselves, are not tracked by git.
# The symlinks are not tracked because they could point to different places on different machines, e.g. with different usernames.
#
# These symlinks should be in .gitignore.
# TODO: How to do this automatically?
ln -n -s -f /etc/apt/sources.list apt/sources.list
ln -n -s -f /etc/apt/sources.list.d apt/sources.list.d
ln -n -s -f /var/lib/apt apt/aptdir
ln -n -s -f /var/lib/aptlogs apt/aptlogs
ln -n -s -f /var/lib/dpkgdir apt/dpkgdir
ln -n -s -f /usr/share/applications ./freedesktop.org/applications
ln -n -s -f /usr/share/applications ./freedesktop.org/applications
# Query the vim version.
# Note that it is expected that the system runs just one version of vim when invoked on the command line,
# although other vims may be installed, so VIMRUNTIME_NUMBER should be the same from any shell.
# This would not be the case with different vim versions installed and accessible by different PATHs e.g. in a login vs non-login shell.
VIMRUNTIME_NUMBER="$(vim --version | head -1 | sed -En -e 's/^VIM - Vi IMproved ([[:digit:]]+\.[[:digit:]]+) .*$/\1/' -e 's/\.//p')"
ln -n -s -f "/usr/local/share/vim/vim$VIMRUNTIME_NUMBER" ./vim/system_runtime
ln -n -s -f "$HOME/.local/share/applications" ./freedesktop.org/user_applications
ln -n -s -f "$HOME/.local/lib/python3.10/" ./python/local_python3.10
ln -n -s -f "$HOME/.python_history" ./python/python_history
ln -n -s -f "$HOME/config/qutebrowser" ./qutebrowser/qutebrowser
ln -n -s -f "$HOME/config/scripts" ./scripts/scripts
ln -n -s -f "$HOME/.bash_history" ./shell/bash_history
ln -n -s -f "$HOME/.terminfo" ./terminal/terminfo

# ~/.local/share/applications.
# The system saves files in here, so don't want to copy those to this repo.
# Currently can't think of a nice symlink-overlay solution. Possible?
# overlayfs possibly, but way too much to do for such a simple thing. Also I think this supposes read-only for underlying directory.
cp freedesktop.org/user_applications_overrides/*.desktop ~/.local/share/applications
