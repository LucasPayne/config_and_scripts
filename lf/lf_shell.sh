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
        cat "$selection_file"
        echo
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
        cat "$selection_file"
        echo
        echo '--------------------------------------------------------------------------------'
    fi
}

# lf selection command
lfs ()
{
    local lf_runtime_dir="$XDG_RUNTIME_DIR/lf"
    local selection_file="$lf_runtime_dir/primary_selection"
    if [ -f "$selection_file" ]
    then
        cat "$selection_file"
        # lf is not adding a new-line
        echo
    else
        >&2 "error: no selection file"
        return 1
    fi
}
