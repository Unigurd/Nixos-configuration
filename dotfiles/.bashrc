# Bash will source this file when run over ssh
# even if it non-interactive. Prevent this.
[[ "$-" != *i* ]] && return

EDITOR=vi

alias g=git

# The label functions need to change current dir
# so they need to be bash functions and so be sourced
source gurd-label.sh
