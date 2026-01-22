# Bash will source this file when run over ssh
# even if it's non-interactive. Prevent this.
[[ "$-" != *i* ]] && return

# Silence direnv when entering a directory with a .envrc
export DIRENV_LOG_FORMAT=

EDITOR=emacsclient

alias g=git

# The label functions need to change current dir
# so they need to be bash functions and so be sourced
# source gurd-label.sh

# `uv` saves its tools here so I need it to be in PATH at work
export PATH=~/.local/bin:$PATH

## Avoid x11-ssh-askpass popping up a graphical prompt when
## using git as git will use SSH_ASKPASS when GIT_ASKPASS is unset.
export GIT_ASKPASS=""

alias ll='ls -lh'

gurdprompt() {
  longprompt='\[\033]2;\h:\u:\w\007\]\n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] '
  shortprompt='\[\033[1;32m\]\$\[\033[0m\] '

  case "$1" in
    "-l" | "--long")
      PS1="$longprompt"
      ;;
    "-s" | "--short")
      PS1="$shortprompt"
      ;;
    "")
      if [[ "$PS1" == "$longprompt" ]]
      then
        PS1="$shortprompt"
      else
        PS1="$longprompt"
      fi
      ;;
    *)
      echo "gurdprompt: Invalid argument: '$1'"
    esac
}

alias gp=gurdprompt

gp -l
