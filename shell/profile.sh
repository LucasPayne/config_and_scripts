export SHELL=bash
export CONFIG_DIR=~/config
export DRIVE_DIR=~/drive
export NOTES_REPO_DIR=~/notes

export SCREENDIR=~/.screen

export EDITOR=vim

export PATH="$PATH:$CONFIG_DIR/scripts"
export PATH="$PATH:$NOTES_REPO_DIR:$PATH"
export PATH="$PATH:$(realpath ~/.local/bin)"
# Rust packages
export PATH="$PATH:$(realpath ~/.cargo/bin)"
# Go packages
export PATH="$PATH:$(realpath ~/go/bin)"

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
