# This config is source'd by lf for every bash subshell.
# (This is not a default lf feature, can for example use BASH_ENV when
#  launching lf to tell bash subprocesses to load this file.)

# Save selection to selection file
save-selection ()
{
    selection_file="$lf_user_runtime_dir/$lf_user_selection_file"

    >"$selection_file"
    if [ ! -z "$fs" ]
    then
        while read -r entry
        do
            realpath "$entry" >> "$selection_file"
        done < <(echo "$fs")
    fi
}

# Load selection from selection file
load-selection ()
{
    selection_file="$lf_user_runtime_dir/$lf_user_selection_file"
    if [ ! -f "$selection_file" ]
    then
        lf -remote "send $id echoerr \"No selection file\""
        exit 1
    fi
    lf -remote "send $id unselect"
    if [ -s "$selection_file" ]
    then
        remote_cmd="send $id toggle"
        while read -r line
        do
            #todo: Quoting
            remote_cmd="$remote_cmd \"$line\""
        done < <(cat "$selection_file")
        lf -remote "$remote_cmd"
    fi
}

# Save focus to focus file.
save-focus ()
{
    focus_file="$lf_user_runtime_dir/$lf_user_focus_file"
    if [ ! -z "$f" ]
    then
        echo "$f" > "$focus_file"
    else
        >"$focus_file"
    fi
}

# Load focus from focus file.
load-focus ()
{
    focus_file="$lf_user_runtime_dir/$lf_user_focus_file"
    if [ ! -f "$focus_file" ]
    then
        lf -remote "send $id echoerr \"No focus file\""
        exit 1
    fi
    focus="$(cat "$focus_file")"
    if [ ! -z "$focus" ]
    then
        ls -remote "send $id select \"$focus\""
    fi
}
