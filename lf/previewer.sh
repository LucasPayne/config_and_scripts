#!/bin/bash

f=$1
width=$2
height=$3
horizontal_position=$4
vertical_position=$5

if [ -d "$f" ]
then
    if [ "$lf_user_readmes" -eq 1 ]
    then
        # Display readme if any.
        readmes=("readme.md" "readme.txt" "readme")
        for readme in "${readmes[@]}"
        do
            found="$(fd -i -p "$f/$readme" .)"
            if [ $? -eq 0 ]
            then
                cat "$(echo "$found" | head -1)"
                break
            fi
        done
    fi
    # # Todo: Match lf usual output.
    ls "$f"
    exit 0
fi

case "$f" in
    *.tar*)
        tar tf "$f"
        ;;
    *.zip)
        unzip -l "$f"
        ;;
    *.rar)
        unrar l "$f"
        ;;
    *.7z)
        7z l "$f"
        ;;
    *ChangeLog|*changelog) 
        source-highlight --failsafe -f esc --lang-def=changelog.lang --style-file=esc.style -i "$f"
        ;;
    *Makefile|*makefile) 
        source-highlight --failsafe -f esc --lang-def=makefile.lang --style-file=esc.style -i "$f"
        ;;
    *) source-highlight --failsafe --infer-lang -f esc --style-file=esc.style -i "$f"
        ;;
esac
