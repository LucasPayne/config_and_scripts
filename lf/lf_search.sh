#!/bin/bash

dir="$(pwd)"

files="$(fd | sed 's/\/$//')"

runtime_dir=~/.local/share/lf/search
if [ ! -d "$runtime_dir" ]
then
    mkdir -p "$runtime_dir"
fi
tmpdir="$(mktemp -d --tmpdir="$runtime_dir" XXXX)"

get_name ()
{
    file="$1"

    # Count the number of path separators "/" to determine the depht,
    # not counting escaped slashes "\/"
    {
        r1="${file//\//}"
        r2="${file//\\\//}"
        num_slash=$(( ${#file} - ${#r1} ))
        num_escaped_slash=$(( ( ${#file} - ${#r2} ) / 2 ))
        depth=$(( num_slash - num_escape_slash + 1 ))
    }
    shortname="$(basename "$file")"
    shortdir="$(dirname "$file" | sed 's/\//@/g')"
    printf '%d\x1F%s\x1F%s\n' "$depth" "$shortname" "$shortdir"
}

names=$(column -s $'\x1F' -t < <(
    while read -r file
    do
        get_name "$file"
    done < <(echo "$files")
))

echo "$names"

#     name=$(get_name $(basename "$file")"
# 
#     ln -s "$dir/$file" "$tmpdir/$name"
# ls -l "$tmpdir"
# 
# rm -r "$tmpdir"
# echo "$tmpdir"
