#!/bin/bash
#
# fzf_tools

print_sep () {
    printf %$(tput cols)s |tr " " "-"
    echo
}

# Determine the percentage to pass to fzf --preview-window=right:N%,
# to align well with the search list.
get_fzf_right_box_percent () {

    # cclean, so color codes don't change calculations.
    # todo: cclean should be a separate command
    sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | 
    {
        # Determine the maximum number of characters of a line from stdin.
        local max_width
        max_width=$(($(wc -L)+1))

        local left_box_width=$((max_width + 3))
        local terminal_cols=$(tput cols)
        local box_percent=$(( 100 - (100*left_box_width)/terminal_cols ))
        if [ "$box_percent" -le 45 ] ; then
            echo 45
        else
            echo $box_percent
        fi
    }
}

# Generic file and directory preview.
fzf_file_preview () {
    filename="$1"

    if [ -L "$filename" ] ; then
        echo "$filename -> $(realpath "$filename")"
    else
        echo "$filename"
    fi
    print_sep
    if [ -f "$filename" ] ; then
        if ( file -b "$filename" | grep -q -i "ascii text" ) || ( file -b "$filename" | grep -q -i "unicode" ) ; then
            if ! source-highlight -q -f esc --style-file ~/.source-highlight/datadir/esc.style -i "$filename" -o STDOUT 2>/dev/null ; then
            # if ! pygmentize "$filename" 2>/dev/null ; then
                cat "$filename"
            fi
        else
            echo "**BINARY**"
            file "$filename"
        fi
    elif [ -d "$filename" ] ; then
        (
            cd "$filename"
            #Actually, a tree can be too noisy.
            #find -L . -mindepth 1 -maxdepth 1 -type d -not -path '/.' -printf "%P\n" | while read -r dir ; do
            #    tree --noreport "$dir"
            #done
            #find -L . -mindepth 1 -maxdepth 1 -type f -not -path '/.' -printf "%P\n" | while read -r f ; do
            #    echo "$f"
            #done
            ls
        )
    fi
}

__fzf_git_branch_preview () {

    git_query="$1"

    shift

    local OPTIND o n q
    n=-1
    while getopts ":n:q:" o ; do
        case "$o" in
            n)
                n="$OPTARG"
                ;;
            q)
                q="$OPTARG"
                ;;
            *)
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    local head_filter
    if [[ "$n" -eq -1 ]] ; then
        head_filter="cat"
    else
        head_filter="head -n $((n-2))"
    fi

    # (
    # $git_query | $head_filter | while read -r line ; do
    #     printf \'
    #     echo "$line" | cut -c 3-
    # done
    # )

    $git_query | $head_filter | (
    while read -r line ; do
        printf \'
        echo "$line" | cut -c 3-
    done
    ) | (
        if [[ "$n" -eq -1 ]] ; then
            # If printing everything, avoid tabulating the output,
            # as the column command takes a long time.
            sed 's/#/   /g'
        else
            column -s'#' -t
        fi
    )
}

# Preview for branches while selecting a branch.
fzf_git_branch_preview () {
    # Usage:
    #   fzf_git_branch_preview BRANCH_NAME [-n NUM_LINES]

    local branch_name="$1"
    shift
    # __fzf_git_branch_preview "git log --pretty=format:\"%ad#%an#%s\" --date=short $branch_name" "$@"
    __fzf_git_branch_preview "git log --pretty=format:%ad#%an#%s --date=short $branch_name" "$@"
}

# Preview for remote branches while selecting a branch.
fzf_git_remote_branch_preview () {

    local branch_name="$1"
    shift
    __fzf_git_branch_preview "git log -r --pretty=format:%ad#%an#%s --date=short $branch_name --" "$@"
}
