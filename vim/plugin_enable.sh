#!/bin/bash
#
# Add a symbolic link into bundle/.
# Plugins can be disabled just by deleting this symbolic link.
#
# Note that the full path including repos/ is used.
# This is for autocompletion convenience.
#

usage () {
    echo "Usage:"
    echo "    ./plugin_enable.sh path/to/plugin"
}

if [ "$#" -ne 1 ] ; then
    usage
    exit 1
fi
path="$1"

if [ ! -d "$path" ] ; then
    echo "Directory \"$path\" does not exist."
    exit 1
fi

name="$(basename "$path")"

if [[ -e "bundle/$name" ]] ; then
    echo "Plugin \"$name\" is already enabled."
    exit 1
fi

ln -s -r "$path" "bundle/$name"
echo "Enabled plugin \"$name\""
