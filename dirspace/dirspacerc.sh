
schematic="$CONFIG_DIR/dirspace/schematics/schematic.txt"

$DIRSPACE_RUNTIME/slots

cur_slot=0
cur_dir=
cur_vim_servername=
while IFS= read -r line
do
    if ! [[ "$line" =~ ^[[:space:]] ]]
    then
        # Give the previous dirspace some time to initialize.
        # TODO: Speed up schematic loading.
        if [ $cur_slot -ne 0 ]
        then
            sleep 1
        fi

        cur_dir="$line"
        cur_vim_servername="$(dirspace_open "$line")"
        ((cur_slot++))

        # Give the dirspace some time to initialize.
        sleep 1
    else
        if [ -z "$cur_dir" ]
        then
            # error, started with indent. Just skip it.
            continue
        fi

        file="$(echo "$line" | sed 's/^[[:space:]]*//')"
        # TODO proper quoting
        # --doesn't work
        # VIM_SERVERNAME="$cur_vim_servername" vim_remote_expr "execute(\"tabnew \"..shellescape($(vim_escape_string "$file")))"
        VIM_SERVERNAME="$cur_vim_servername" vim_remote_expr "execute(\"tabnew $file\")"
        VIM_SERVERNAME="$cur_vim_servername" vim_remote_expr "execute(\"tabnext 1\")"
        VIM_SERVERNAME="$cur_vim_servername" vim_remote_expr "SetDirspaceSlot($cur_slot)"
    fi
done < <(cat "$schematic")
