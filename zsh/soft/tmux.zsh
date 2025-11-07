#!/bin/zsh

# Autostart tmux

if ! is_arg_present "$IS_PREVIEW" && ! is_in_tmux; then
    if [[ $TERM != "linux" ]]; then
        if is_command_present tmuxinator; then
            tmuxinator start empty
        else
            tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf new-session -As main
        fi
    fi
else
    export TERM="screen-256color"
fi
