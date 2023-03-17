
export CONFIG_DIR=~/config
export DRIVE_DIR=~/drive

export PATH="$PATH:$(realpath ~/bin)"
export PATH="$PATH:$CONFIG_DIR/scripts"
export PATH="$PATH:$(realpath ~/.cargo/bin)"

# Vulkan development
export VULKAN_DEV_PATH="$(realpath ~/drive/dev/vulkan)"
export PATH="$PATH:$VULKAN_DEV_PATH/bin"
export PATH="$PATH:$VULKAN_DEV_PATH/scripts"
export MANPATH="$MANPATH:$VULKAN_DEV_PATH/man"
export RENDERDOC_SOURCE_PATH="$VULKAN_DEV_PATH/renderdoc"
export PATH="$PATH:$RENDERDOC_SOURCE_PATH/build/bin"

setxkbmap us
source $CONFIG_DIR/scripts/syncer_files/syncer-bash.sh
alias man='COLUMNS=120 man'
alias .sb="source ~/.bashrc"

source "$CONFIG_DIR/scripts/fzf_tools/fzf_tools.sh"

# Risk it...
alias sudo='sudo env PATH=$PATH'

set -o vi

alias gdb='gdb -q'
export GDB_DEV="$(realpath ~/drive/dev/gdb)"

alias p=python3
alias python=python3

export LESS="--mouse --wheel-lines=3"


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

# Remove ANSI colour commands.
cclean () {
    sed "s,\x1B\[[0-9;]*[a-zA-Z],,g"
}

# Using xargs as a simple for-loop syntax.
# Separate output by printing each input line.
xarg () {
    while read -r line ; do
        c16 blue
        echo "$line"
        c16 --reset
        echo "$line" | xargs  -L 1 -I {} "$@"
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

# Vim server
#    ...
#<<<

# Globals
export VIM_SESSION_BASH_SOURCE_FILE="/tmp/vim_session_bash_source.sh"

# vimreset is called when the vim server is quit.
# todo: Think of a better way to let the server communicate the server is closed
# when vim is quit. Using the temp files is unwieldy.
vimreset () {
    unset VIM_SERVER_ID
    unset VIM_SERVER_PID
    unset VIM_SERVER_JOB_SPEC
}

# v [FILE] [LINE]
# Open the vim server (optionally with a file, and optionally a certain line).
# If the vim server for this environment is active, then this is in a new tab.
v () {
    local vim_session_bash_source_file="$VIM_SESSION_BASH_SOURCE_FILE"

    if [ -f /tmp/vimdir ] ; then rm /tmp/vimdir ; fi

    local open_cmd
    # Note: Having a file named --tabnew breaks the argument processing.
    if [ "$#" -ge 1 ] && [ "$1" = "--tabnew" ] ; then
        open_cmd="tabnew"
        shift
    else
        open_cmd="edit!"
    fi

    {
    # To-do: Better argument and flag handling.
    if [ "$#" -eq 1 ] ; then
        local filename=$(realpath "$1")
        vimattachserver ":$open_cmd $filename<CR>" "edit $filename"
    elif [ "$#" -eq 2 ] ; then
        local filename=$(realpath "$1")
        local linenumber=$2
        vimattachserver ":$open_cmd $filename<CR>:normal! ${linenumber}gg<CR>" "edit $filename | normal! ${linenumber}gg"
    elif [ "$#" -eq 3 ] && [ "$2" == "-S" ] ; then
        local filename=$(realpath "$1")
        local source_file=$(realpath "$3")
        vimattachserver ":$open_cmd $filename | source $source_file<CR>" "edit $filename | source $source_file"
    else
        vimattachserver "" ""
    fi ;
    } && fg "$VIM_SERVER_JOB_SPEC" > /dev/null;
    {
        if [ -f /tmp/vimdir ] ; then
            cd $(cat /tmp/vimdir)
        fi

        if [ -f /tmp/${VIM_SERVER_ID}_vim_server_closed ] ; then
            local val=$(cat /tmp/${VIM_SERVER_ID}_vim_server_closed)
            # When back to the terminal, if the vim server was quit, then clear the vim server data.
            if [[ ( "$val" == 1 ) ]] ; then
                vimreset
            fi
        fi
    }

    # Source custom tmp file. This allows the vim server to write out commands the host bash should run after vim suspends.
    # One use is to have vim invoke bash-level vim-server commands, such as to open a new file in the same session.
    # Note: Sourcing a tmp file is pretty dangerous...

    # As the source could open the vim-server again, the file needs to be removed _before_ the source. So it needs a local copy
    # for this shell.
    if [ -f "$vim_session_bash_source_file" ] ; then
        local local_source_file="$(cat "$vim_session_bash_source_file")"
        rm "$vim_session_bash_source_file"
        source <(echo "$local_source_file")
    fi
}

# Helper function to find or create the vim server.
vimattachserver () {
    servercmd=$1
    newcmd=$2

    if [ -z "$VIM_SERVER_ID" ] ; then
        export VIM_SERVER_ID="$RANDOM"
        { vim --servername $VIM_SERVER_ID -c "$newcmd" & } 2>/dev/null
        # Indicate that the vim server is open.
        echo "0" > /tmp/${VIM_SERVER_ID}_vim_server_closed

        export VIM_SERVER_PID="$!"
        VIM_SERVER_JOB_SPEC=$( jobs -l | sel $(jobs -l -p | grep -n $VIM_SERVER_PID | cclean | awk -F ':' '{ print $1 }') | awk '{ print $1 }' )
        export VIM_SERVER_JOB_SPEC=${VIM_SERVER_JOB_SPEC:1:-2}

        # echo "vim server id: " $VIM_SERVER_ID
        # echo "vim server pid: " $VIM_SERVER_PID
        # echo "vim server job_spec: " $VIM_SERVER_JOB_SPEC
    else
        vim --servername "$VIM_SERVER_ID" --remote-send "$servercmd"
    fi
}

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
        # fd -L --search-path "$dir" $depth_flags -tf | cut -c 3-
        find -L "$dir" $find_depth_flags -type f -not -name '*.link' -a -not -path '*.git/*' | cut -c 3-
        find -L "$dir" $find_depth_flags -type f -name '*.link' -a -not -path '*.git/*' | cut -c 3- | awk '{print "\033[35m" $0  "\033[0m"}'
        fd -L --search-path "$dir" $fd_depth_flags -td | cut -c 3-  | rev | cut -c 2- | rev | awk '{print "\033[34m" $0  "\033[0m"}'
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
                    # v --tabnew "$selected"

                    # Alternatively, follow the directory.
                    dir="./$selected"
                    start_query_string="$selected/ "

                    continue
                else
                    if [ "$follow_link" -eq 1 ] ; then
                        firefox /tmp/link.html > /dev/null 2>&1 &
                        continue
                    else
                        v --tabnew "$selected"
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


#>>>

# Readline bindings
#    ...
#<<<

# Shortcut to reopen vim session.
bind -m vi-insert '"\ew": "\C-uv\n"'
bind -m vi-command '"\ew": "\C-uv\n"'

# Navigate forward
bind -m vi-command '"\el": "\C-u\C-lfzf_navigate './'\n"'
bind -m vi-insert '"\el": "\C-u\C-lfzf_navigate './'\n"'
# Navigate forward, begin in recursive mode.
bind -m vi-command '"\er": "\C-u\C-lfzf_navigate './' --recursive\n"'
bind -m vi-insert '"\er": "\C-u\C-lfzf_navigate './' --recursive\n"'
# Navigate backward
bind -m vi-command '"\eh": "\C-ucd ..\n"'
bind -m vi-insert '"\eh": "\C-ucd ..\n"'

bind -m vi-command '"\ef": "\C-u\C-lfzf_find\n"'
bind -m vi-insert '"\ef": "\C-u\C-lfzf_find\n"'

#>>>

# Prompt
#    ...
#<<<
git_prompt () {
    local branch=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/') 
    if [ ! -z "$branch" ] ; then
        local branch="($branch)"
    fi
    echo -e "$branch"
}

dir_prompt () {
    local drive_prefix_string="="
    local storage_prefix_string="---"
    local home_prefix_string="~"

    local dir="$(realpath .)"
    local drive_prefix="$(realpath ~/drive)"
    local storage_prefix="$(realpath ~/storage)"
    local home_prefix="$(realpath ~)"
    if ( echo "$dir" | grep -q "^$drive_prefix" ) ; then
        local dir="$drive_prefix_string$(echo "$dir" | cut -c $((${#drive_prefix}+1))-)"
    elif ( echo "$dir" | grep -q "^$storage_prefix" ) ; then
        local dir="$storage_prefix_string$(echo "$dir" | cut -c $((${#storage_prefix}+1))-)"
    elif ( echo "$dir" | grep -q "^$home_prefix" ) ; then
        local dir="$home_prefix_string$(echo "$dir" | cut -c $((${#home_prefix}+1))-)"
    fi
    echo -e "$dir"
}

PS1=''
#PS1=$PS1'$(c16 grey)\u@\h$(c16 --reset)'
PS1=$PS1'\[\033[01;32m\]\u@\h\[\033[00m\]:'
PS1=$PS1'$(c16 white)$(dir_prompt)$(c16 --reset):'
PS1=$PS1'$(c16 blue)$(git_prompt)$(c16 --reset)\n\$ '
#>>>


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
