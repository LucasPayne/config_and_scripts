
# If config moves, update this.
export CONFIG_DIR=~/config

export PATH="$PATH:$(realpath ~/bin)"
export PATH="$PATH:$CONFIG_DIR/scripts"

setxkbmap us
source ~/code/syncer/syncer-bash.sh
alias v=vim
alias man='COLUMNS=120 man'
alias .sb="source ~/.bashrc"

alias fd=fdfind
