#
#
# todo:
# Silence job control.
# https://stackoverflow.com/questions/11097761/is-there-a-way-to-make-bash-job-control-quiet

lfcd ()
{
    local debug=1

    local lf_runtime_dir="$XDG_RUNTIME_DIR/lf"
    mkdir -p "$lf_runtime_dir"
    local selection_file="$lf_runtime_dir/primary_selection"
    if [ ! -e "$selection_file" ]
    then
        touch "$selection_file"
    elif [ ! -f "$selection_file" ]
    then
        >&2 echo "Something is in the way of $selection_file"
        return 1
    fi

    if [ $debug -eq 1 ]
    then
        echo "$selection_file"
        echo '--------------------------------------------------------------------------------'
        lfs
        echo '--------------------------------------------------------------------------------'
    fi

    local tmp="$(mktemp)"
    # `command` is needed in case `lfcd` is aliased to `lf`
    command lf -command="load-selection \"$selection_file\"" -print-selection -selection-path="$selection_file" -last-dir-path="$tmp" "$@" &
    local lf_server_id="$$"
    fg

    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi

    if [ $debug -eq 1 ]
    then
        echo "$selection_file"
        echo '--------------------------------------------------------------------------------'
        lfs
        echo '--------------------------------------------------------------------------------'
    fi
}

# lf selection command
lfs ()
{
    local lf_runtime_dir="$XDG_RUNTIME_DIR/lf"
    local selection_file="$lf_runtime_dir/primary_selection"

    if [ ! -f "$selection_file" ]
    then
        >&2 "error: no selection file"
        return 1
    fi

    if [ ! -t 0 ]
    then
        # Input from a pipe.
        # Interpret stdin as selections.
        local append_mode
        if [ $# -eq 1 ] && [ "$1" = -a ]
        then
            # append selections
            append_mode=1
        else
            # overwrite selections
            append_mode=0
        fi

        if [ $append_mode -eq 0 ]
        then
            >"$selection_file"
        fi

        # This block is only to help when handling lf's newline behaviour
        # when writing the selection file.
        local initial_empty=0
        if [ ! -s "$selection_file" ]
        then
            initial_empty=1
        fi

        local out_index=0
        while read -r line
        do
            if [ ! -e "$line" ]
            then
                >&2 echo "File \"$line\" doesn't exist, ignoring."
            else
                if [ $initial_empty -eq 0 ] && [ $out_index -eq 0 ]
                then
                    # Handle lf's newline behaviour when writing the selection file.
                    echo >> "$selection_file"
                fi

                local out_line="$(realpath "$line")"
                echo "$out_line" >> "$selection_file"
                ((out_index++))
            fi
        done < <(cat)
        # Remove last newline from selection file.
        # (lf does this when it writes selection files itself.)
        # This has no effect if the file is empty.
        truncate -s -1 "$selection_file"
        
        exit 0
    fi

    if [ $# -eq 0 ]
    then
        if [ -s "$selection_file" ]
        then
            cat "$selection_file"
            # lf is not adding a new-line
            echo
        fi
    elif [ $# -eq 1 ]
    then
        if [ "$1" = "-c" ]
        then
            # Clear selection file
            >"$selection_file"
        fi
    else
        >&2 echo "bad args"
        return 1
    fi
}
