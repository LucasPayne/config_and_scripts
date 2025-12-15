# Interactive shell aliases.
#
# These should only make sense in an interactive shell,
# e.g., with job control, file redirection, whether or not to use a pager.
# Anything like an alias to a program, e.g. z=zathura,
# should instead be in a wrapper exec script in PATH, e.g.
# z```
#    #!/bin/sh
#    exec zathura "$@"
# ```

alias man='COLUMNS=90 man'
alias .sb="source ~/.bashrc"
# https://superuser.com/questions/1551566/why-does-sudo-env-path-path-do-anything-at-all
alias sudoo='sudo env PATH=$PATH'
alias stracee='strace 2>&1'
alias gdb='gdb -q'
alias ls="ls --color=auto -1 --hyperlink=auto"
alias vless="~/.vim/macros/less.sh"
alias grep='grep --color=auto'
alias k9='kill -9'
alias cls=delete_scrollback
alias feh='feh --borderless'

# Always enable images in w3m.
# If in tty is kitty, use its image protocol (APC G).
w3m_wrapper ()
{
    if [[ "$TERM" = *-kitty* ]]
    then
        w3m -o auto_image=TRUE -o inline_img_protocol=4 "$@"
    else
        w3m "$@"
    fi
}
alias w3m='w3m_wrapper'
