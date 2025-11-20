export SHELL=bash
export CONFIG_DIR=~/config
export DRIVE_DIR=~/drive
export NOTES_REPO_DIR=~/notes

# Dev paths
export ACADEMIA="$HOME/drive/dev/academia"
export COMPUTER="$HOME/drive/dev/computer"
export DOCUMENTATION="$HOME/drive/dev/documentation"
export FILMS="$HOME/drive/dev/films"
export READING="$HOME/drive/dev/reading"
export MAGIC="$HOME/drive/dev/magic"
export PERSON="$HOME/drive/dev/person"
export VISUAL_EFFECTS="$HOME/drive/dev/visual_effects"

export SCREENDIR=~/.screen

export EDITOR=vim

# Linux source code (not necessarily the current kernel's source).
export LSRC=/home/lucas/code/linux

export PATH="$PATH:$CONFIG_DIR/scripts"
export PATH="$PATH:$NOTES_REPO_DIR:$PATH"
export PATH="$PATH:$(realpath ~/.local/bin)"
# Rust packages
export PATH="$PATH:$(realpath ~/.cargo/bin)"
# Go packages
export PATH="$PATH:$(realpath ~/go/bin)"

# dpkg
# Disable paging
export DPKG_PAGER=cat

# GTK
# Force a custom dark theme for accessibility
#
gtk_theme_dir="$(xdg-data-home)/themes/Greybird-dark-override"
if [ -d "$gtk_theme_dir" ] ; then
    export GTK_THEME="Greybird-dark-override"
    export GTK2_RC_FILES="$gtk_theme_dir/gtk-2.0/gtkrc"
else
    export GTK_THEME="Greybird-dark"
fi
# Qt
export QT_SCALE_FACTOR=1
# Force a custom dark theme for accessibility
# Note on apt systems this is installed through the package "adwaita-qt".
# Qt loads styles from a .so plugin. This style can be modified by building
# adwaita-qt from source.
export QT_STYLE_OVERRIDE=Adwaita-Dark

# Man pages in synced config.
export MANPATH="$MANPATH:$(realpath ~/config/man)"

# Vulkan development
export VULKAN_DEV_PATH="$(realpath ~/drive/dev/vulkan)"
export PATH="$PATH:$VULKAN_DEV_PATH/bin"
export PATH="$PATH:$VULKAN_DEV_PATH/scripts"
export MANPATH="$MANPATH:$VULKAN_DEV_PATH/man"
export RENDERDOC_SOURCE_PATH="$VULKAN_DEV_PATH/renderdoc"
export PATH="$PATH:$RENDERDOC_SOURCE_PATH/build/bin"

# Make sure the path doesn't get too long.
export PATH="$(unique-path)"
# Allow user binaries to override system binaries.
export PATH="$(realpath ~/bin):$PATH"

# Preferably this would be in source-highlight.conf, but that can't expand HOME.
# (See info source-highlight)
export SOURCE_HIGHLIGHT_DATADIR="$HOME/config/source-highlight/datadir"

export GDB_DEV="$HOME/config/gdb"
