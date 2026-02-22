#!/bin/zsh

# Change suggestion strategy: history first, then completion
# 'completion' doesn't work right now
# https://github.com/zsh-users/zsh-autosuggestions/issues/751
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Set the suggestion highlight style (default is underline)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8a8a8a,bold"

# Set buffer max size (increase if needed)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Only consider recent history entries more relevant
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *|ls *|pwd|exit"

# Disabling automatic widget re-binding
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
