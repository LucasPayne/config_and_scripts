# This file is source'd by login shells, both interactive and non-interactive.
# (https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html)

if [ -f ~/.profile ]
then
    source ~/.profile
fi

if [ -f ~/.bashrc ]
then
    source ~/.bashrc
fi
