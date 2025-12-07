
schematic="$CONFIG_DIR/dirspace/schematics/schematic.txt"

cur_dir=
cur_vim_servername=
while IFS= read -r line
do
    if ! [[ "$line" =~ ^[[:space:]] ]]
    then
        cur_dir="$line"
        cur_vim_servername="$(dirspace_open "$line")"
        # Give it some time to initialize.
        # TODO: Speed up schematic loading.
        sleep 1
    else
        if [ -z "$cur_dir" ]
        then
            # error, started with indent. Just skip it.
            continue
        fi

        file="$(echo "$line" | sed 's/^[[:space:]]*//')"
        VIM_SERVERNAME="$cur_vim_servername" vim_remote_expr "execute(\"tabnew \"..shellescape($(vim_escape_string "$file")))"
        VIM_SERVERNAME="$cur_vim_servername" vim_remote_expr "execute(\"tabnext 1\")"
    fi
done < <(cat "$schematic")
