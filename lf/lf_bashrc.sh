# This config is source'd by lf for every bash subshell.
# (This is not a default lf feature, can for example use BASH_ENV when
#  launching lf to tell bash subprocesses to load this file.)

# TODO: Move this to on-init (release 34), so don't have to run each subshell.
# X-- This appears not to work, I think lf_ vars are only initialized after BASH_ENV rc.
#     So, just manually make the my_runtime dir until release 34.
# if [ ! -d "$lf_user_my_runtime_prefix" ]
# then
#     echo "prefix: $lf_user_my_runtime_prefix"
#     mkdir -p "$lf_user_my_runtime_prefix"
# fi
# TODO: Also this, it doesn't need to be a function called repeatedly.
my_runtime()
{
    lf_pid="$(ppid $$)"
    runtime="$lf_user_my_runtime_prefix/$lf_pid"
    if [ -d "$runtime" ]
    then
        rm -r "$runtime"
    fi
    mkdir "$runtime"
    echo "$runtime"
}

get_readme ()
{
    local f="$1"
    local readmes=("readme.md" "readme.txt" "readme")
    for readme in "${readmes[@]}"
    do
        local found
        found="$(fd -d2 -i -p "$f/$readme" .)"
        if [ $? -eq 0 ]
        then
            echo "$found" | head -1
            return 0
        fi
    done
    return 1
}

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

# Should duplicate behaviour in ~/.bashrc,
# but using the current lf session.
# note: Don't have to override UI, can keep it more in flow with current lf session.
lf-checkout-find ()
{
    local checkout_root_path="$1"
    lf -remote "send $id :cd \"$checkout_root_path\"; set preview; push f"
}
