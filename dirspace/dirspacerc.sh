
schematic="$CONFIG_DIR/dirspace/schematics/schematic.txt"

cur_slot=1
init_slot=1
cur_dir=
cur_vim_servername=
while IFS= read -r line
do
    if ! [[ "$line" =~ ^[[:space:]] ]]
    then
        # Give the previous dirspace some time to initialize.
        # TODO: Speed up schematic loading.
        # -- Is this needed for the vim commands to surely execute in the right
        #     one before the next dirspace is opened?
        #     Try uncomment if there are bugs.
        # if [ $cur_slot -ne 1 ]
        # then
        #     sleep 1
        # fi
        
        # Check for @ initial dirspace tag.
        if [[ "$line" =~ ^@ ]]
        then
            # Set as initial slot.
            init_slot=$cur_slot
            line="${line#@}"
        fi

        cur_dir="$line"
        cur_vim_servername="$(dirspace_open "$line")"

        # Give the dirspace some time to initialize.
        sleep 1
    
        # Set the slot
        VIM_SERVERNAME="$cur_vim_servername" vim_remote_expr "SetDirspaceSlot($cur_slot)"
        ((cur_slot++))
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
    fi
done < <(cat "$schematic")

# Switch to the init slot (default 1).
screen -X select $init_slot
