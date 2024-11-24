setxkbmap us

source $CONFIG_DIR/scripts/syncer_files/syncer-bash.sh

source "$CONFIG_DIR/scripts/fzf_tools/fzf_tools.sh"

set -o vi
# https://unix.stackexchange.com/questions/12107/how-to-unfreeze-after-accidentally-pressing-ctrl-s-in-a-terminal
# Deactivate terminal-driver-level flow control.
if [ -t 1 ]
then
    stty -ixon
fi

# Explicit terminfo needed for some reason, when using built-from-source ncurses.
export TERMINFO=/lib/terminfo

export LESS="-R --mouse --wheel-lines=3"
#https://www.gnu.org/software/src-highlite/source-highlight.html#Introduction
export LESSOPEN="| ~/.source-highlight/src-hilite-lesspipe.sh %s"

export PATH="$PATH:/usr/share/doc/git/contrib/diff-highlight"

#https://www.imagemagick.org/include/resources.php#environment
export MAGICK_CONFIGURE_PATH="$CONFIG_DIR/imagemagick/user_config"

# scr: create script
# Usage:
#     scr script_name     Go to scripts, create, git add, chmod, ...
#     ................... edit script in vim, write short description on the second line.
#     scr                 Git add again, commit with script description.
scr ()
{
    if [ $# -ne 1 ]
    then
        if [ ! -z ${LAST_SCRIPT_CREATED_WITH_SCR+x} ]
        then
            local script="$CONFIG_DIR/scripts/$LAST_SCRIPT_CREATED_WITH_SCR"
            local description="$(cat "$script" | sel 2)"
            git add "$script"
            git commit -m "${description:2}"
            unset LAST_SCRIPT_CREATED_WITH_SCR
            return 0
        else
            echo "LAST_SCRIPT_CREATED_WITH_SCR is not set." 2>&1
            return 1
        fi
    fi
    cd "$CONFIG_DIR/scripts"
    local name="$1"
    if echo "$name" | grep -q '/'
    then
        echo "name must not contain forward slashes" 2>&1
        return 1
    fi
    if [ -f "$name" ]
    then
        echo "script \"$name\" exists" 2>&1
        return 1
    fi
    if [ -d "$name" ]
    then
        echo "\"$name\" is a directory" 2>&1
        return 1
    fi
    cat > "$name" <<-EOF
	#!/bin/bash
	# $name:
	
	EOF
    git add "$name"
    chmod a+x "$name"
    LAST_SCRIPT_CREATED_WITH_SCR="$name"
    v "$name"
    # todo: Go to last line in vim.
}

newconfig ()
{
    # newconfig: Create a new config subdirectory.
    # If already exists, just go to it.
    
    if [ $# -ne 1 ]
    then
        >&2 echo "Usage: newconfig <config name>"
        return 1
    fi
    local name="$1"
    local newconfig_path="$CONFIG_DIR/$name"
    if [ -d "$newconfig_path" ]
    then
        cd "$newconfig_path"
    elif [ -e "$newconfig_path" ]
    then
        >&2 echo "FIle \"$name\" already exists in config."
        return 1
    else
        cd "$CONFIG_DIR"
        mkdir "$name"
        ./make_ascii_readmes.sh
        cd "$name"
    fi
}

# Check out git project to code directory.
gitget ()
{
    local name=""
    if [ $# -eq 1 ]
    then
        local url="$1"
    elif [ $# -eq 2 ]
    then
        local url="$1"
        local name="$2"
    else
        >&2 echo "Usage:"
        >&2 echo "    gitget <url>"
        >&2 echo "    gitget <name> <url>"
        return 1
    fi
    if [ -z "$name" ]
    then
        name="$(basename --suffix=.git "$url")"
        if [ $? -ne 0 ]
        then
            >&2 echo "error: Couldn't determine name of project"
            return 1
        fi
    fi

    cd ~/code
    if [ -d "$name" ]
    then
        echo "$name already exists, cd'ing to it..."
        cd "$name"
        return 0
    elif [ -e "$name" ]
    then
        >&2 echo "error: File \"$name\" exists in code directory."
        return 1
    fi
    git clone "$url" "$name"
    cd "$name"
}

# bash history with default, no numbers
hist ()
{
    local n=10
    if [ $# -gt 0 ]
    then
        n="$1"
        shift
    fi
    history "$n" "$@" | sed 's/^ [0-9]\+  //'
}

xdg-mime-set ()
{
    xdg-mime default feh.desktop image/jpeg
    xdg-mime default feh.desktop image/png
    xdg-mime default feh.desktop image/gif
    xdg-mime default feh.desktop image/gif
    xdg-mime default org.pwmt.zathura.desktop application/pdf
}


# Small utilities
#    ...
#<<<
# Select the n'th line of stdin.
sel () {
    sed "$1q;d"
}

# Split by : delimiter.
splitc () {
    tr ":" "\n"
}

# Using xargs as a simple for-loop syntax.
# Separate output by printing each input line.
xarg () {
    while read -r line ; do
        #c16 blue
        >&2 echo "$line"
        #c16 --reset
        echo "$line" | xargs -I {} "$@"
    done
}
# Invoke command for each line, with each line as standard input.
sarg () {
    while read -r line ; do
        c16 blue
        echo "$line"
        c16 --reset
        echo "$line" | "$@"
    done
}

# https://unix.stackexchange.com/questions/88296/get-vertical-cursor-position
cursor_row () {
    local COL
    local ROW
    IFS=';' read -sdR -p $'\E[6n' ROW COL
    echo "${ROW#*[}"
}


#>>>

# termdesk and vim servers
#    ...
#<<<
cd ()
{
    builtin cd "$@"
    if [ ! -z "$VIMSERVER_ID" ] && [ ! -z "$TERMDESK_PRIMARY_SHELL" ] ; then
        vim --servername "$VIMSERVER_ID" --remote-send '<C-\><C-n>:cd '"$(/bin/pwd)"'<cr>A'
    fi
    # Store the directory in the id temporary file.
    # This is used in vim, which otherwise can't access non-symlink-resolved paths.
    if [ ! -z "$VIMSERVER_ID" ] ; then
        pwd > "$VIMSERVER_ID"
    fi
}

# edit-and-execute-command (C-x C-e emacs, v vi)
# detect if in a vim terminal. If so, tell it to integrate the editing buffer.
# (e.g. vim is free to create a new tab, to overlay the shell's terminal, or use a popup, etc.)
export VISUAL=vim-terminal-editor
export EDITOR=vim-terminal-editor
# Set the editor for git.
# This could also be set with
#    git config --global core.editor "vim-terminal-editor"
export GIT_EDITOR=vim-terminal-editor

#>>>

# Navigation
#    ...
#<<<
__fzf_navigate () {
    local dir="$1"
    local start_query_string="$2"
    local recursive="$3"

    local dir_list
    local file_list

    local select_list="$( (
        local depth_flags
        if [ "$recursive" -eq 0 ] ; then
            fd_depth_flags="--min-depth 1 --max-depth 1"
            find_depth_flags="-mindepth 1 -maxdepth 1"
        else
            fd_depth_flags="--min-depth 1"
            find_depth_flags="-mindepth 1"
        fi

        # find "$dir" $depth_flags -type d -not -path '*/\.git/*' | cut -c 3- \
        # | awk '{print "\033[34m" $0  "\033[0m"}'
        # find "$dir" $depth_flags -type f -not -path '*/\.git/*' | cut -c 3-

        # Note: Using fd instead of find (faster?).
        #TODO: Show symlinks which are files but not directories
        #fd -L --search-path "$dir" $depth_flags -tf | cut -c 3-
        find -L "$dir" $find_depth_flags -type f -not -name '*.link' -a -not -path '*.git/*' | cut -c 3-
        find -L "$dir" $find_depth_flags -type f -name '*.link' -a -not -path '*.git/*' | cut -c 3- | awk '{print "\033[35m" $0  "\033[0m"}'
        fd -L --search-path "$dir" $fd_depth_flags -td | cut -c 3- | awk '{print "\033[34m" $0  "\033[0m"}'
    ) | tac)"


    HEIGHT_MODE=1
    if [ "$HEIGHT_MODE" -eq 0 ] ; then
        # Match height to initial search list.
        local height=$(($(echo "$select_list" | wc -l) + 2))
        # Adjust the height to be at least some lines long.
        local min_height=16
        height=$min_height

    elif [ "$HEIGHT_MODE" -eq 1 ] ; then
        # Match height to terminal.
        local height=$(($(tput lines) - $(cursor_row)))
    fi


    local preview_percent
    preview_percent=$(echo "$select_list" | get_fzf_right_box_percent)
    if [ "$preview_percent" -ge 75 ] ; then
        preview_percent=75
    fi

    local preview_command_string="source $CONFIG_DIR/scripts/fzf_tools/fzf_tools.sh ; fzf_file_preview {}"

    echo "$select_list" | fzf \
        -i \
        --height=$height \
        --bind 'enter:execute(echo "FILE_EDIT")+accept' \
        --bind 'alt-enter:execute(echo "FILE_EDIT_TAB")+accept' \
        --bind "alt-p:execute($preview_command_string  | less -r > /dev/tty 2>&1)" \
        --bind 'alt-o:execute(echo "XDG_OPEN")+accept' \
        --bind 'alt-r:execute(echo "SWITCH_MODE_RECURSIVE")+accept' \
        --bind 'ctrl-w:backward-kill-word' \
        --bind 'alt-e:execute(echo "DIRECTORY_QUERY")+print-query+execute("echo")+abort' \
        --bind 'alt-l:execute(echo "DIRECTORY_FOLLOW")+accept' \
        --bind 'alt-h:execute(echo "DIRECTORY_UP")+accept' \
        --bind 'alt-w:execute(echo "VIM_SESSION_ENTER")+accept' \
        --bind 'alt-space:jump' \
        --bind 'alt-q:execute(echo "DIRECTORY_CD")+accept' \
        --preview="$preview_command_string" \
        --preview-window=right:$preview_percent% \
        --query="$start_query_string" \
        --prompt="./" \
        --filepath-word \
        --layout=reverse \
        --color=16,gutter:-1,hl:yellow:regular,hl+:yellow:regular,bg+:-1,fg+:-1:regular \
        --ansi \
        --border=none

        # --bind 'alt-w:backward-kill-word' \
        # --bind 'alt-l:replace-query' \
        # --bind 'alt-e:replace-query' \
        # --bind 'alt-w:execute(echo "QUERY_BACK_UP")+print-query+execute("echo")+abort' \


}

fzf_navigate () {
    # Arg: directory

    local dir
    local start_query_string
    # Normalize the dir name to the form ./ or ./path/to/thing/
    if [ "$1" = './' ]  ; then
        dir='./'
        start_query_string=""
    else
        dir="$(dirname "$1")/$(basename "$1")"
        start_query_string="$(echo "$dir" | cut -c 3-)"
    fi

    local recursive
    # Optionally start in recursive mode.
    if [ "$#" -ge 2 ] && [ "$2" = "--recursive" ] ; then
        recursive=1
    else
        recursive=0
    fi

    # The fzf prompt is initialized with a list repeatedly,
    # while the "dir" changes.
    # This is not the shell working directory. If an action causes
    # the shell working directory to change, the fzf prompt has to be fully reset
    # (including the above preamble), so this is signified with do_restart=1.
    do_restart=0
    while true ; do
        # echo "dir=$dir"

        clear
        echo " Shell: $(pwd)"
        echo " @: $dir"
        local output="$(__fzf_navigate "$dir" "$start_query_string" "$recursive")"

        local command="$(echo "$output" | head -n 1)"
        local DONT_FOLLOW_LINKS=0
        if [[ $command == *__DONT_FOLLOW_LINKS ]] ; then
            # Special "command flag" used to force non-link operations.
            # (Implemented here for editing link files without opening them in the browser.)
            DONT_FOLLOW_LINKS=1
            command="${command%__DONT_FOLLOW_LINKS}"

        fi

        local selected="$(echo "$output" | tail -n 1)"

        local follow_link=0
        if [ "$DONT_FOLLOW_LINKS" -eq 0 ] && [[ "$selected" == *.link ]] ; then
            # Prepare to open .link files (containing one line with a url) with a browser.

            # Extract the url.
            local link="$(cat "$selected" | sed '/^[[:space:]]*$/d'| head -n 1 | tr -d '\n')"

            # html stub
            # (not needed)
            cat <<-EOF > /tmp/link.html
<html>
<head>
<meta http-equiv="refresh" content="0; url=$link" />
</head>
</html>
EOF
            follow_link=1
        fi

        # echo $command
        # echo $selected

        # https://unix.stackexchange.com/questions/146942/how-can-i-test-if-a-variable-is-empty-or-contains-only-spaces
        # if [[ -z "${selected// }" ]] ; then
        #     break
        # fi

        case $command in
            FILE_EDIT )
                if [ -d "$selected" ] ; then
                    # Open the directory in Ex.
                    # Put special case here if needed.
                    # v "$selected"
                    # break

                    # Alternatively, follow the directory.
                    dir="./$selected"
                    start_query_string="$selected/"

                    continue
                else
                    if [ "$follow_link" -eq 1 ] ; then
                        firefox /tmp/link.html > /dev/null 2>&1 &
                        wmctrl -a firefox
                        continue
                    else
                        v "$selected"
                        continue
                    fi
                fi
                continue
                ;;
            FILE_EDIT_TAB )
                if [ -d "$selected" ] ; then
                    # Open the directory in Ex.
                    # Put special case here if needed.
                    # Alternatively, follow the directory.
                    dir="./$selected"
                    start_query_string="$selected/ "

                    continue
                else
                    if [ "$follow_link" -eq 1 ] ; then
                        firefox /tmp/link.html > /dev/null 2>&1 &
                        continue
                    else
                        v "$selected"
                        continue
                    fi
                fi
                ;;
            DIRECTORY_FOLLOW )
                if [ -d "$selected" ] ; then
                    dir="./$selected"
                    start_query_string="$selected/"

                else
                    # "Follow" a file by just putting the full path in the prompt.
                    # (For the feeling of "going to the end".)
                    start_query_string="$selected"
                    # Also, set the dir to that file's dir (this is useful in recursive mode).
                    dir="./$(dirname "$selected")"
                    if [ "$dir" = "./." ] ; then
                        # TODO: Is there a better way to normalize paths in this way?
                        dir="."
                    fi
                fi
                continue
                ;;
            DIRECTORY_QUERY )
                # Note: $selected is here used for the query string.
                local query="$selected"

                # Look for a directory matching the query string (file or directory).
                # (This is useful for example to go to recursive mode, find a file,
                #   complete the query to that combo, Ctrl-W up a couple directories, then
                #   switch to that directory.)
                # If this doesn't work, just reset the prompt.

                # Go to the root of the search if the query is empty.
                if [[ -z "${query// }" ]] ; then
                    dir="./"
                    start_query_string=''
                #TODO: query=="DIRECTORY_QUERY" is a bug.
                elif [ "$query" == "DIRECTORY_QUERY" ] ; then
                    dir="./"
                    start_query_string=''
                elif [ -d "$query" ] ; then
                    dir="$(dirname "$query")/$(basename "$query")/"
                    start_query_string="$(echo "$dir" | cut -c 3-)"
                elif [ -f "$query" ] ; then
                    in_dir="$(dirname "$query")"
                    dir="$(dirname "$in_dir")/$(basename "$in_dir")/"
                    start_query_string="$(echo "$dir" | cut -c 3-)"
                fi
                continue
                ;;
            DIRECTORY_CD )
                cd "$dir"
                break
                ;;
            DIRECTORY_UP )
                # If the prompt is empty, start making the shell go up directories.
                if [[ -z "${start_query_string// }" ]] ; then
                    cd ..
                    do_restart=1
                    break
                fi
                continue
                #TODO: This was clobbered accidentally before version control...
                # # Otherwise, kill a path separator.
                # continue
                # cd ".."
                # dir="$(pwd)"
                # start_query_string=""
                # continue
                ;;
            SWITCH_MODE_RECURSIVE )
                recursive=$((1-recursive))
                continue
                ;;
            VIM_SESSION_ENTER )
                # Go into the vim session from the navigator. Exiting the vim session will then
                # come back to the navigator.
                v
                continue
                ;;
            XDG_OPEN )
                # Go into the vim session from the navigator. Exiting the vim session will then
                # come back to the navigator.
                xdg-open "$selected" &
                continue
                ;;
        esac
        break

    done

    if [ "$do_restart" -eq 1 ] ; then
        # Restart in a different working directory.
        fzf_navigate "$dir"
    fi
}

fzf_find () {
    # Consider cf usage as example for what is needed.
    # For pure text search I sometimes correlate two keywords.
    # For example, cf "GPUInstancingNode" will give every occurence, but
    # this can be piped to grep for "class", which will likely winnow the choices down a lot.
    # However, a pure grep/fuzzy-search will remove the nice structuring of ack-style output.
    # So, somehow need to get this style output.
    # Could initially create a flag vimgrep-style, then strip out the metadata (so just the pure lines).
    # Then pipe this through rg again (as stdin, so one file), output in vimgrep-style, and use the line numbers
    # manually filter out the pretty-printed ack output.
    # https://github.com/BurntSushi/ripgrep/issues/875

    # (This might be more suited for fuzzy-finding in all files, but that could be slow, or the output might
    #  be less readable (try this?).)


    rg -p -i $(echo | fzf --ansi --preview='rg -p -i {q}' --preview-window='right:90%' --bind='alt-q:execute(rg -p -i {q} | fzf --layout=reverse --ansi --preview="echo nice")+accept' --bind='alt-p:execute(rg -p -i {q} | less -r > /dev/tty 2>&1)')
}

# Search for two patterns and then pretty-print.
rg_double () {
    local pattern1="$1"
    local pattern2="$2"
    local rg_out=$(rg "$pattern1" --line-number --with-filename --no-heading --color=always)
    # Determine the positions in rg_out which have a double match.
    # (file-line metadata is stripped from rg_out before grepping again.)
    local double_match_numbers="$(echo "$rg_out" | cut -d':' -f 3- | rg "$pattern2" --line-number --no-filename | cut -d':' -f 1)"

    # Extract these lines from rg_out, to get a flat list of double matches.
    local sed_line_list
    sed_line_list="$(echo "$double_match_numbers" | tr '\n' ';' | sed 's/;/p;/g')"
    sed_line_list="$(printf "%s" "$sed_line_list")"
    if [ "$sed_line_list" = "p;" ] ; then
        sed_line_list=""
    fi
    echo "$rg_out" | sed -n "$sed_line_list"
    # | ack_oneline_to_heading
}

# Jump to a directory, displaying readme files.
fzf_checkout () {
    local dir="$1"
    local preview_string=$(cat <<- 'EOT'
	# Look for readme files.
	found="$(find DIR_STRING/{} -mindepth 1 -maxdepth 1 -iname readme\* | sort)"
	# Prefer a markdown readme if possible.
	declare -a mds
	mds=($(echo "$found" | grep -e '\.md$'))
	if (( ${#mds[@]} > 0 )) ; then
	    readme=${mds[0]}
	else
	    readme=$(echo "$found" | head -1)
	fi
        bat --color=always --style=grid <(echo {})
	bat --color=always --style=plain $readme
	EOT
    )
    # A bit of a hack to expand just the dir variable in the preview string.
    local preview_string=$(echo "$preview_string" | sed "s@DIR_STRING@$dir@g")
    local list="$(find $dir -mindepth 1 -maxdepth 1 -type d -not -name '.*' | xargs -L 1 basename | grep -E -v '^~')"
    while read -r user_directory ; do
        if [[ -z "${user_directory// }" ]] ; then
            continue
        fi
        subdirs="$(find $dir/$user_directory -mindepth 1 -maxdepth 1 -type d | 
            while read -r dirpath ; do
                # Extract the last two directories in the path (e.g. ~user/project).
                echo "$(basename $(realpath "$dirpath/.."))/$(basename "$dirpath")"
            done)"
        list="$(printf "$list\n$subdirs")"
    done <<<$(find $dir -mindepth 1 -maxdepth 1 -type d | xargs -L 1 basename | grep -E '^~')
    list="$(echo "$list" | sort)"

    local preview_percent=$(echo "$list" | get_fzf_right_box_percent)
    if [ "$preview_percent" -ge 85 ] ; then
        local preview_percent=85
    fi
    local selected=$(echo "$list" |
        fzf --preview="$preview_string" \
            --preview-window=right:$preview_percent% \
            --color=16,gutter:-1,hl:yellow:regular,hl+:yellow:regular,bg+:-1,fg+:-1:regular \
            --bind='alt-l:execute(echo "__OPEN_FILE_BROWSER")+accept' \
            --bind='ctrl-alt-l:execute(echo "__OPEN_FILE_BROWSER_NO_CD")+accept' \
            --ansi \
            --layout=reverse \
            --border=none
    )
    # Try to extract command from first line of output of lf.
    local command="$(echo "$selected" | head -n 1)"
    local opt_open_file_browser=0
    local opt_no_cd=0
    if [[ $command == __OPEN_FILE_BROWSER* ]] ; then
        opt_open_file_browser=1
        selected="$(echo "$selected" | tail +2)"
        if [[ $command == "__OPEN_FILE_BROWSER_NO_CD" ]] ; then
            opt_no_cd=1
        fi
        if [ ! -z "$selected" ]
        then
            if [ $opt_open_file_browser -eq 1 ]
            then
                if [ $opt_no_cd -eq 1 ]
                then
                    lf "$dir/$selected"
                else
                    cd "$dir/$selected"
                    lfcd
                fi
            else
                cd "$dir/$selected"
            fi
        fi
    fi
}
fzf_code_checkout ()
{
    fzf_checkout ~/code
}
fzf_dev_checkout ()
{
    fzf_checkout ~/drive/dev
}
fzf_config_checkout ()
{
    fzf_checkout "$CONFIG_DIR"
}
fzf_select_notes ()
{
    local preview_string=$(cat <<- 'EOT'
	cat {}
	EOT
    )
    fd . -ens ~/notes/notes.d \
        | fzf --preview="$preview_string" \
              --preview-window=right:80% \
              --color=16,gutter:-1,hl:yellow:regular,hl+:yellow:regular,bg+:-1,fg+:-1:regular \
              --ansi \
              --layout=reverse \
              --border=none
}

#>>>

# Git
#    ...
#<<<
# View and checkout branches.

# Pretty display
GIT_LOG_FORMAT_PRETTY_DISPLAY="$(c16 blue)%h $(c16 cyan)%an $(c16 red)%ar$(c16 --reset)%n    %s%n"

gcb () {
    if ! git status >/dev/null 2>&1 ; then
        echo "Not in a git repo."
        return
    fi
    local branches=$(git branch | while read -r branch ; do
                        branch=${branch#* }
                        echo $branch
                    done)
    local num_branches=$(echo "$branches" | wc -l)
    local prompt_height=$((num_branches < 14 ? 14 : num_branches))
    local preview_string='bat --color=always --style=grid <(echo {}) ; git log --oneline --format="'"$GIT_LOG_FORMAT_PRETTY_DISPLAY"'" {} -- | '"head -$((prompt_height-3))"
    chosen=$( echo "$branches" | fzf --preview="$preview_string" \
                --height=$((prompt_height + 2)) \
                --color=16,gutter:-1,hl:yellow:regular,hl+:yellow:regular,bg+:-1,fg+:-1:regular \
                --bind='alt-l:accept' \
                --preview-window=right:80% \
                --layout=reverse
            )
    if [ ! -z "$chosen" ] ; then
        git checkout "$chosen"
    fi
}

preview_git_log () {
    if ! git status >/dev/null 2>&1 ; then
        echo "Not in a git repo."
        return
    fi
    local ref="$1"

    local current_branch="$(git rev-parse --abbrev-ref HEAD)"
    (
        bat --color=always --style=grid <(echo "$(realpath . | xargs basename):($current_branch)")
        git log $ref --oneline --format="$GIT_LOG_FORMAT_PRETTY_DISPLAY" | cat
    ) | less -r
}


#>>>

# Readline bindings
#    ...
#<<<

vi_bind ()
{
    bind -m vi-command "$@"
    bind -m vi-insert "$@"
}

# Navigation
vi_bind '"\el": "\C-ulfcd\n"'
# search
vi_bind '"\er": "\C-ulfcd -command=\"set preview; set ratios 1:2; push f\"\n"'
# Navigate backward
vi_bind '"\eh": "\C-ucd ..\n"'

vi_bind '"\ef": "\C-u\C-lfzf_find\n"'

# fzf_code_checkout
vi_bind '"\eq": "\C-u\C-lfzf_code_checkout\n"'

# fzf_dev_checkout
vi_bind '"\ee": "\C-u\C-lfzf_dev_checkout\n"'

# fzf_config_checkout
vi_bind '"\ei": "\C-u\C-lfzf_config_checkout\n"'
#
# fzf open notes file
vi_bind '"\en": "\C-u\C-lfzf_select_notes | x v\n"'

# checkout branch
vi_bind '"\eo": "\C-ugcb\n"'

# preview git log
#bind -m vi-command '"\ea": "\C-upreview_git_log HEAD\n"'
#bind -m vi-insert '"\ea": "\C-upreview_git_log HEAD\n"'
# tig
vi_bind '"\ea": "\C-utig\n"'

# Job control
vi_bind '"\C-z": "\C-ufg-next\n"'
vi_bind '"\ez": "\C-ufg-next\n"'

#>>>

# Prompt
#    ...
#<<<

PS1=''
PS1=$PS1'\[\033[01;32m\]\u@\h\[\033[00m\]$(prompt)\n\$ '
#>>>

# Job control
#    ...

_fg-job ()
{
    local indicator_symbol="$1"
    while read -r job_line
    do 
        # `jobs -l` outputs [N]+ for the next foreground job.
        # Search for this and capture the pid (printed with -l).
        if [[ $job_line =~ ^\[[0-9]+\]"$indicator_symbol"[[:space:]]*([0-9]+)[[:space:]] ]]
        then
            local pid="${BASH_REMATCH[1]}"
            echo "$pid"
            return 0
        fi
    done < <(jobs -l)

    >&2 echo "no job found"
    return 1
}

# Get the job which will be next under the "fg" command.
# This is not yet a foreground job (the shell is), until fg is run.
fg-job ()
{
    _fg-job +
}
# Get the job second in line for the fg command.
fg-job-second ()
{
    _fg-job -
}

# Get the job number next in the job list.
# This is not the same as the "second" job indicated by -.
# This is useful for cycling through jobs.
fg-next-job-spec ()
{
    local current
    current="$(fg-job)"
    [ $? -ne 0 ] && return $?
    # job number start at 1,
    # but "index" here starts at 0.
    local index=$(("$(jobs -p | grep -n -E "^$current$" | cutc 1)" - 1))
    local num_jobs=$(jobs -p | wc -l)
    local next_index=$(((index + 1) % num_jobs))
    if [[ $(jobs | sel $((next_index + 1))) =~ \[([0-9]+)\] ]]
    then
        echo "${BASH_REMATCH[1]}"
    else
        return 1
    fi
}

fg-next ()
{
    local job_spec
    job_spec="$(fg-next-job-spec)"
    [ $? -ne 0 ] && return $?
    fg "$job_spec"
}

source "$CONFIG_DIR/lf/lf_shell.sh"

# MISC
#--------------------------------------------------------------------------------
# learning x86
#<<<
export X86_DEV_PATH="$(realpath ~/drive/dev/x86)"
export MANPATH="$MANPATH:$X86_DEV_PATH/man"
# Todo: move this
ins () {
    local names_cache="$X86_DEV_PATH/man/.names_cache"
    if [ ! -f "$names_cache" ] ; then
        ls "$X86_DEV_PATH/man/man7" | while read -r page ; do
            echo "$page" | cut -d- -f 2 | cut -d'.' -f 1 >> "$names_cache"
        done
    fi

    cat "$names_cache" |
    fzf --preview='man x86-{}.7'\
        --color=bw\
        --bind "alt-p:execute(man x86-{}.7 | less -r > /dev/tty 2>&1)"\
        --preview-window=right:80%
}
#>>>

source ~/.bash_aliases
