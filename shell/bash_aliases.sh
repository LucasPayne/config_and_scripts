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

alias man='COLUMNS=120 man'
alias .sb="source ~/.bashrc"
# https://superuser.com/questions/1551566/why-does-sudo-env-path-path-do-anything-at-all
alias sudo='sudo env PATH=$PATH'
alias stracee='strace 2>&1'
alias gdb='gdb -q'
alias ls="ls --color=auto"
alias vless="~/.vim/macros/less.sh"
alias grep='grep --color=auto'
alias k9='kill -9'
