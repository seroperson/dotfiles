#!/bin/zsh

# <file.txt equals to cat file.txt
READNULLCMD=cat

# window title
DISABLE_AUTO_TITLE="true"
case $TERM in
  *xterm*|rxvt*|screen*|(dt|k|E)term)
    precmd () {
      print -Pn "\e]0;%n %~\a"
    }
    preexec () {
      print -Pn "\e]0;%n %~ {$1}\a"
    }
    ;;
esac

# {{{ options
# read more at zsh.sourceforge.net/doc/release/options.html

# don't write duplicate lines to history
setopt HIST_IGNORE_DUPS
# be able to edit history entry before executing
setopt HIST_VERIFY
# share history immediately between terminals
setopt SHARE_HISTORY
# don't beep when there is no any history entry
unsetopt HIST_BEEP

# allow to use comments
setopt INTERACTIVE_COMMENTS
# cd to the directory just by typing its name
setopt AUTO_CD
# don't close application after ^Z
setopt NO_HUP
# don't warn after minimizing
setopt NO_CHECK_JOBS
setopt COMPLETE_IN_WORD
unsetopt LIST_AMBIGUOUS
# https://unix.stackexchange.com/a/34012
setopt nullglob

# }}}

# don't freeze by c-s
stty ixany
stty ixoff -ixon

# remap interrupting to ^e
stty intr \^E
