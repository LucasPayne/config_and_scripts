#!/bin/bash
#
# Set up the configuration symlinks.
#
# todo:
#    Ask for confirmation if a file would be deleted.

# xdg/freedesktop.org stuff
# On debian, the variables
#    XDG_DATA_HOME
#    XDG_CONFIG_HOME
#    XDG_CACHE_HOME
# are not set, as they have well-defined default values in the specification:
# Just in case these variables are set on the current system, use them, and if not, follow the defaults described in the spec:
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
set_xdg_dir()
{
    varname=$1
    xdg_varname=$2
    xdg_default=$3
    if [[ -v $xdg_varname ]] ; then
        declare -g $varname="$xdg_varname"
        echo "$varname: $xdg_varname"
    else
        declare -g $varname="$xdg_default"
        echo "$varname: $xdg_default"
    fi
    declare xdg_data_home=nice
}
set_xdg_dir xdg_data_home XDG_DATA_HOME "$HOME/.local/share"
set_xdg_dir xdg_config_home XDG_CONFIG_HOME "$HOME/.config"
set_xdg_dir xdg_cache_home XDG_CACHE_HOME "$HOME/.cache"
#TODO: "XDG_LOCAL_HOME"? See spec.

# Setup symlinks on system to this config dir.
ln -n -s -f "$(realpath vim/runtime)" ~/.vim
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
ln -n -s -f "$(realpath readline/inputrc)" ~/.inputrc
ln -n -s -f "$(realpath pager/lesskey.txt)" ~/.lesskey
ln -n -s -f "$(realpath git/gitconfig)" ~/.gitconfig

# See `man tig`'s FILES section.
mkdir -p "$xdg_config_home/tig"
ln -n -s -f "$(realpath git/tigrc)" "$xdg_config_home/tig/config"

ln -n -s -f "$(realpath i3)" ~/.i3
ln -n -s -f "$(realpath scripts)" ~/scripts
ln -n -s -f "$(realpath source-highlight)" ~/.source-highlight
ln -n -s -f "$(realpath lf)" "$xdg_config_home/lf"
ln -n -s -f "$(realpath qutebrowser)" "$xdg_config_home/qutebrowser"
ln -n -s -f "$(realpath nvim)" "$xdg_config_home/nvim"
ln -n -s -f "$(realpath debian/dpkg.cfg)" ~/.dpkg.cfg
ln -n -s -f "$(realpath freedesktop.org/autostart)" "$xdg_config_home/autostart"
ln -n -s -f "$(realpath cool-retro-term/cool-retro-term-share)" "$xdg_data_home/cool-retro-term"
ln -n -s -f "$(realpath cool-retro-term/cool-retro-term-config)" "$xdg_config_home/cool-retro-term"

# Setup symlinks in this directory to system files.
# This is for convenient navigation of config. The directory contents, and the symlinks themselves, are not tracked by git.
# The symlinks are not tracked because they could point to different places on different machines, e.g. with different usernames.
#
# These symlinks should be in .gitignore.
# TODO: How to do this automatically?
ln -n -s -f /etc/inputrc readline/system_inputrc
ln -n -s -f /etc/apt/sources.list debian/sources.list
ln -n -s -f /etc/apt/sources.list.d debian/sources.list.d
ln -n -s -f /var/lib/apt debian/aptdir
ln -n -s -f /var/log/apt debian/aptlogs
ln -n -s -f /var/lib/dpkg debian/dpkgdir
ln -n -s -f /usr/share/applications ./freedesktop.org/applications
ln -n -s -f "$HOME/.local" "./freedesktop.org/local"
ln -n -s -f "$xdg_config_home" ./freedesktop.org/config
ln -n -s -f "$xdg_cache_home" ./freedesktop.org/cache
ln -n -s -f /etc/xdg ./freedesktop.org/xdg_dir
ln -n -s -f "$xdg_data_home/Trash" ./freedesktop.org/Trash

# Query the vim version.
# Note that it is expected that the system runs just one version of vim when invoked on the command line,
# although other vims may be installed, so VIMRUNTIME_NUMBER should be the same from any shell.
# This would not be the case with different vim versions installed and accessible by different PATHs e.g. in a login vs non-login shell.
VIMRUNTIME_NUMBER="$(vim --version | head -1 | sed -En -e 's/^VIM - Vi IMproved ([[:digit:]]+\.[[:digit:]]+) .*$/\1/' -e 's/\.//p')"
ln -n -s -f "/usr/local/share/vim/vim$VIMRUNTIME_NUMBER" ./vim/system_runtime

ln -n -s -f "$xdg_data_home/applications" ./freedesktop.org/user_applications
ln -n -s -f "$HOME/.local/lib/python3.10/" ./python/local_python3.10
ln -n -s -f "$HOME/.python_history" ./python/python_history
ln -n -s -f "$xdg_config_home/qutebrowser" ./qutebrowser/qutebrowser
ln -n -s -f "$HOME/.bash_history" ./shell/bash_history
ln -n -s -f "$HOME/.terminfo" ./terminal/terminfo

# ~/.local/share/applications.
# The system saves files in here, so don't want to copy those to this repo.
# Currently can't think of a nice symlink-overlay solution. Possible?
# overlayfs possibly, but way too much to do for such a simple thing. Also I think this supposes read-only for underlying directory.
cp freedesktop.org/user_applications_overrides/*.desktop ~/.local/share/applications
