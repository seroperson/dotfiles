#!/bin/zsh

local tpm_directory=$XDG_CONFIG_HOME/tmux/plugin/tpm

is_file_exists $tpm_directory || git clone git@github.com:tmux-plugins/tpm.git $tpm_directory

if ! is_in_tmux && [[ $TERM != "linux" ]]; then
    tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf new-session -As main
fi
