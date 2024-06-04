#!/bin/bash
#
# Set up the configuration symlinks.
#
# todo:
#    Ask for confirmation if a file would be deleted.

# xdg/freedesktop.org stuff
# On debian, some XDG variables such as XDG_DATA_HOME are not set, as they have well-defined default values in the specification.
# Just in case these variables are set on the current system, use them, and if not, follow the defaults described in the spec:
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
set_xdg_dir()
{
    varname=$1
    xdg_varname=$2
    xdg_default=$3
    if [[ -v $xdg_varname ]] ; then
        declare -g $varname="${!xdg_varname}"
        echo "\$$varname: ${!xdg_varname}"
    else
        declare -g $varname="$xdg_default"
        echo "\$$varname: $xdg_default"
    fi
}
echo "Determining XDG variables..."
set_xdg_dir xdg_config_home XDG_CONFIG_HOME "$HOME/.config"
set_xdg_dir xdg_cache_home XDG_CACHE_HOME "$HOME/.cache"
set_xdg_dir xdg_data_home XDG_DATA_HOME "$HOME/.local/share"
set_xdg_dir xdg_state_home XDG_STATE_HOME "$HOME/.local/state"
set_xdg_dir xdg_config_dirs XDG_CONFIG_DIRS "/etc/xdg"
set_xdg_dir xdg_data_dirs XDG_DATA_DIRS "/usr/local/share:/usr/share"
#TODO: "XDG_LOCAL_HOME"? See spec.
echo

create_link()
{
    target="$1"
    link_name="$2"
    ln -n -s -f "$(realpath -s "$target")" "$link_name"
}
link_system_to_config()
{
    create_link "$1" "$2"
    echo "Put link in system: $link_name ---> $target"
}
link_config_to_system()
{
    create_link "$1" "$2"
    echo "Created navigation link in config: $link_name ---> $target"
}

# Setup symlinks on system to this config dir.
link_system_to_config ./vim/runtime ~/.vim
link_system_to_config ./vim/vimrc.vim ~/.vimrc
link_system_to_config ./emacs/infokey ~/.infokey
link_system_to_config ./shell/profile.sh ~/.profile
link_system_to_config ./shell/bashrc.sh ~/.bashrc
link_system_to_config ./shell/bash_aliases.sh ~/.bash_aliases
link_system_to_config ./shell/bash_profile.sh ~/.bash_profile
link_system_to_config ./shell/bash_logout.sh ~/.bash_logout
link_system_to_config ./gdb/gdbinit.gdb ~/.gdbinit
link_system_to_config ./gdb/ ~/.gdb
link_system_to_config ./X/Xresources.txt ~/.Xresources
link_system_to_config ./X/xinitrc ~/.xinitrc
link_system_to_config ./X/xsession ~/.xsession
link_system_to_config ./screen/screenrc.txt ~/.screenrc
link_system_to_config ./screen/screendir ~/.screen
link_system_to_config ./readline/inputrc ~/.inputrc
link_system_to_config ./pager/lesskey.txt ~/.lesskey
link_system_to_config ./git/gitconfig ~/.gitconfig

# See `man tig`'s FILES section.
mkdir -p "$xdg_config_home/tig"
link_system_to_config ./git/tigrc "$xdg_config_home/tig/config"

link_system_to_config ./i3 "$xdg_config_home/i3"
link_system_to_config ./scripts ~/scripts
link_system_to_config source-highlight ~/.source-highlight
link_system_to_config lf "$xdg_config_home/lf"
link_system_to_config qutebrowser "$xdg_config_home/qutebrowser"
link_system_to_config nvim "$xdg_config_home/nvim"
link_system_to_config debian/dpkg.cfg ~/.dpkg.cfg
link_system_to_config freedesktop.org/autostart "$xdg_config_home/autostart"
link_system_to_config cool-retro-term/cool-retro-term-share "$xdg_data_home/cool-retro-term"
link_system_to_config cool-retro-term/cool-retro-term-config "$xdg_config_home/cool-retro-term"

echo
# Setup symlinks in this directory to system files.
# This is for convenient navigation of config. The directory contents, and the symlinks themselves, are not tracked by git.
# The symlinks are not tracked because they could point to different places on different machines, e.g. with different usernames.
#
# These symlinks should be in .gitignore.
# TODO: How to do this automatically?
link_config_to_system /etc/inputrc ./readline/system_inputrc

# system debian symlinks
link_config_to_system /etc/apt/sources.list debian/sources.list
link_config_to_system /etc/apt/sources.list.d debian/sources.list.d
link_config_to_system /var/lib/apt debian/aptdir
link_config_to_system /var/log/apt debian/aptlogs
link_config_to_system /var/lib/dpkg debian/dpkgdir

# system xdg symlinks
link_config_to_system "$xdg_config_home" ./freedesktop.org/xdg_config_home
link_config_to_system "$xdg_cache_home" ./freedesktop.org/xdg_cache_home
link_config_to_system "$xdg_state_home" ./freedesktop.org/xdg_state_home
link_config_to_system "$xdg_data_home" ./freedesktop.org/xdg_data_home
link_config_to_system "$xdg_data_home/Trash" ./freedesktop.org/Trash
create_xdg_dir_symlinks()
{
    xdg_dirs_var="$1"
    echo "${!xdg_dirs_var}" | tr ':' '\n' | while read -r dirpath
    do
        if [ -d "$dirpath" ] ; then
            mangled_path="$(echo -n "$dirpath" | tr '/' '_' | tr ' ' '_')"
            link_config_to_system "$dirpath" "./freedesktop.org/$xdg_dirs_var@$mangled_path"
        else
            echo "$xdg_dirs_var: $dirpath not found. Not creating symlink."
        fi
    done
}
create_xdg_dir_symlinks xdg_config_dirs
create_xdg_dir_symlinks xdg_data_dirs

# Query the vim version.
# Note that it is expected that the system runs just one version of vim when invoked on the command line,
# although other vims may be installed, so VIMRUNTIME_NUMBER should be the same from any shell.
# This would not be the case with different vim versions installed and accessible by different PATHs e.g. in a login vs non-login shell.
VIMRUNTIME_NUMBER="$(vim --version | head -1 | sed -En -e 's/^VIM - Vi IMproved ([[:digit:]]+\.[[:digit:]]+) .*$/\1/' -e 's/\.//p')"
link_config_to_system "/usr/local/share/vim/vim$VIMRUNTIME_NUMBER" ./vim/system_runtime

link_config_to_system "$xdg_data_home/applications" ./freedesktop.org/user_applications
link_config_to_system "$HOME/.local/lib/python3.10/" ./python/local_python3.10
link_config_to_system "$HOME/.python_history" ./python/python_history
link_config_to_system "$xdg_config_home/qutebrowser" ./qutebrowser/qutebrowser
link_config_to_system "$HOME/.bash_history" ./shell/bash_history
link_config_to_system "$HOME/.terminfo" ./terminal/terminfo

# ~/.local/share/applications.
# The system saves files in here, so don't want to copy those to this repo.
# Currently can't think of a nice symlink-overlay solution. Possible?
# overlayfs possibly, but way too much to do for such a simple thing. Also I think this supposes read-only for underlying directory.
cp freedesktop.org/user_applications_overrides/*.desktop ~/.local/share/applications
