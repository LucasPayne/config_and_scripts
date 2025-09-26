#!/bin/bash

mapfile -t files < <(cat | sed 's/\/$//')

dir="$(pwd)"

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
    if [ -d "$file" ]
    then
        flags="."
    else
        flags=" "
    fi
    prefix="$depth$flags"
    printf '%s\x1F%s\x1F%s\n' "$prefix" "$shortname" "$shortdir"
}

mapfile -t names < <(column -s $'\x1F' -t < <(
    for file in "${files[@]}"
    do
        get_name "$file"
    done
))

for (( i=0 ; i < ${#names[@]} ; i++ ))
do
    name="${names[$i]}"
    file="${files[$i]}"
    ln -s "$dir/$file" "$tmpdir/$name"
done

echo "$tmpdir"
# lf "$tmpdir"
# rm -r "$tmpdir"
