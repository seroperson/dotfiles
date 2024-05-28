#!/bin/zsh

# Autostart tmux

if ! is_in_tmux; then
    if [[ $TERM != "linux" ]]; then
        tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf new-session -As main
    fi
else
    export TERM="screen-256color"
fi
