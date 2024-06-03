#!/bin/bash
# Create README previews using figlet,
#  _ _ _          _   _     _     
# | (_) | _____  | |_| |__ (_)___ 
# | | | |/ / _ \ | __| '_ \| / __|
# | | |   <  __/ | |_| | | | \__ \
# |_|_|_|\_\___|  \__|_| |_|_|___/
#
# This is nice in git web browsers and in some tools which preview READMEs of directories.

# Make sure this creates readmes in the config directories relative to the script.
cd "$(dirname "$(readlink -f "$0")")"

if ! command -v figlet &>/dev/null ; then
    >&2 echo "Cannot find figlet. Is it installed?"
    >&2 echo "With apt, the package name is \"figlet\"."
    exit 1
fi

find -mindepth 1 -maxdepth 1 -type d | while read -r dirpath ; do
    readme_path="$dirpath/README.md"
    > "$readme_path"
    echo '```' >> "$readme_path"
    figlet "$(basename "$dirpath")" >> "$readme_path"
    echo '```' >> "$readme_path"
    git add "$readme_path"
done
