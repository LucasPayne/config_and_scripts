
export CONFIG_DIR=~/config
export DRIVE_DIR=~/drive

export PATH="$PATH:$(realpath ~/bin)"
export PATH="$PATH:$CONFIG_DIR/scripts"
# Rust packages
export PATH="$PATH:$(realpath ~/.cargo/bin)"
# Go packages
export PATH="$PATH:$(realpath ~/go/bin)"

export MANPATH="$MANPATH:$(realpath ~/man)"

alias fd=fdfind

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

alias vs=vimshell

alias gdb='gdb -q'
export GDB_DEV="$(realpath ~/.gdb)"

# Explicit terminfo needed for some reason, when using built-from-source ncurses.
export TERMINFO=/lib/terminfo

alias p=python3
alias python=python3

export LESS="-R --mouse --wheel-lines=3"
#https://www.gnu.org/software/src-highlite/source-highlight.html#Introduction
export LESSOPEN="| ~/.source-highlight/src-hilite-lesspipe.sh %s"

alias ls="ls --color=auto"

alias vless="~/.vim/macros/less.sh"

export PATH="$PATH:/usr/share/doc/git/contrib/diff-highlight"


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
cd ()
{
    builtin cd "$@"
    if [ ! -z "$VIMSHELL_ID" ] ; then
        vim --servername "$VIMSHELL_ID" --remote-send '<C-\><C-n>:cd '"$@"'<cr>A'
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
    local list="$(find $dir -mindepth 1 -maxdepth 1 -type d | xargs -L 1 basename)"
    local preview_percent=$(echo "$list" | get_fzf_right_box_percent)
    if [ "$preview_percent" -ge 85 ] ; then
        local preview_percent=85
    fi
    local selected=$(echo "$list" |
        fzf --preview="$preview_string" \
            --preview-window=right:$preview_percent% \
            --color=16,gutter:-1,hl:yellow:regular,hl+:yellow:regular,bg+:-1,fg+:-1:regular \
            --bind='alt-l:accept' \
            --ansi \
            --layout=reverse \
            --border=none
    )
    if [ ! -z "$selected" ] ; then
        cd $dir/$selected
    fi
}
fzf_code_checkout () {
    fzf_checkout ~/code
}
fzf_dev_checkout () {
    fzf_checkout ~/drive/dev
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

# Shortcut to reopen vim session.
bind -m vi-insert '"\ew": "\C-uv\n"'
bind -m vi-command '"\ew": "\C-uv\n"'

# Navigate forward
#bind -m vi-command '"\el": "\C-u\C-lfzf_navigate './'\n"'
#bind -m vi-insert '"\el": "\C-u\C-lfzf_navigate './'\n"'
bind -m vi-command '"\el": "\C-u\C-llfcd\n"'
bind -m vi-insert '"\el": "\C-u\C-llfcd\n"'
# Navigate forward, begin in recursive mode.
bind -m vi-command '"\er": "\C-u\C-lfzf_navigate './' --recursive\n"'
bind -m vi-insert '"\er": "\C-u\C-lfzf_navigate './' --recursive\n"'
# Navigate backward
bind -m vi-command '"\eh": "\C-ucd ..\n"'
bind -m vi-insert '"\eh": "\C-ucd ..\n"'

bind -m vi-command '"\ef": "\C-u\C-lfzf_find\n"'
bind -m vi-insert '"\ef": "\C-u\C-lfzf_find\n"'

# fzf_code_checkout
bind -m vi-command '"\eq": "\C-u\C-lfzf_code_checkout\n"'
bind -m vi-insert '"\eq": "\C-u\C-lfzf_code_checkout\n"'

# fzf_dev_checkout
bind -m vi-command '"\ee": "\C-u\C-lfzf_dev_checkout\n"'
bind -m vi-insert '"\ee": "\C-u\C-lfzf_dev_checkout\n"'

# checkout branch
bind -m vi-command '"\eo": "\C-ugcb\n"'
bind -m vi-insert '"\eo": "\C-ugcb\n"'

# preview git log
#bind -m vi-command '"\ep": "\C-upreview_git_log HEAD\n"'
#bind -m vi-insert '"\ep": "\C-upreview_git_log HEAD\n"'
# tig
bind -m vi-command '"\ep": "\C-utig\n"'
bind -m vi-insert '"\ep": "\C-utig\n"'

#>>>

# Prompt
#    ...
#<<<
prompt () {
    local dir="$(pwd)"
    local prefix="$(realpath -s ~/drive/dev)"
    if [ "$(pwd)" != "$prefix" ] && ( echo "$dir" | grep -q "^$prefix" ) ; then
        local tmp="$(echo "$dir" | cut -c $((${#prefix}+1))-)"
        local project="$(echo $tmp | cut -d/ -f 2)"
        local rest="$(echo $tmp | cut -d/ -f 3-)"
        local desc_file=~/drive/dev/.desc
        local desc=$(cat $desc_file | grep "^$project desc/" | cut -d/ -f 2-)
        local color=$(cat $desc_file | grep "^$project color/" | cut -d/ -f 2-)
        printf ":$(c16 $color)$desc$(c16 --reset)"
        if [ ! -z "$rest" ] ; then
            printf "/"
        fi
        local dir="$rest"
    else
        local drive_prefix_string="="
        local storage_prefix_string="---"
        local home_prefix_string="~"

        local dir="$(pwd)"
        local drive_prefix="$(realpath -s ~/drive)"
        local storage_prefix="$(realpath -s ~/storage)"
        local home_prefix="$(realpath -s ~)"
        if ( echo "$dir" | grep -q "^$drive_prefix" ) ; then
            local dir="$drive_prefix_string$(echo "$dir" | cut -c $((${#drive_prefix}+1))-)"
        elif ( echo "$dir" | grep -q "^$storage_prefix" ) ; then
            local dir="$storage_prefix_string$(echo "$dir" | cut -c $((${#storage_prefix}+1))-)"
        elif ( echo "$dir" | grep -q "^$home_prefix" ) ; then
            local dir="$home_prefix_string$(echo "$dir" | cut -c $((${#home_prefix}+1))-)"
        fi
    fi
    local branch=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/') 

    c16 white
    printf "$dir"
    c16 --reset

    if [ ! -z "$branch" ] ; then
        printf ":$(c16 blue)($branch)$(c16 --reset)"
    fi
}

PS1=''
PS1=$PS1'\[\033[01;32m\]\u@\h\[\033[00m\]$(prompt)\n\$ '
#>>>


lfcd ()
{
    tmp="$(mktemp)"
    # `command` is needed in case `lfcd` is aliased to `lf`
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}


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
