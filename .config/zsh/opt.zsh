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

# {{{ default-options
# read more at zsh.sourceforge.net/doc/release/options.html

setopt INTERACTIVE_COMMENTS # allow to use comments
setopt AUTO_CD # cd to the directory just by typing its name
setopt NO_HUP # don't close application after ^Z
setopt NO_CHECK_JOBS # don't warn after minimizing
setopt COMPLETE_IN_WORD
unsetopt LIST_AMBIGUOUS
setopt nullglob # https://unix.stackexchange.com/a/34012

# }}}

# {{{ history options

setopt BANG_HIST # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS # Do not display a line previously found.
setopt HIST_IGNORE_SPACE # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY # Don't execute immediately upon history expansion.
unsetopt HIST_BEEP # Don't beep when accessing nonexistent history.


# }}}

# don't freeze by c-s
stty ixany
stty ixoff -ixon

# remap interrupting to ^e
stty intr \^E
