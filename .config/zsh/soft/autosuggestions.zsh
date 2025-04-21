#!/bin/zsh

# Configuration for zsh-autosuggestions

# Change suggestion strategy: history first, then completion
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Set the suggestion highlight style (default is underline)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8a8a8a,bold"

# Set buffer max size (increase if needed)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Only consider recent history entries more relevant
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *|ls *|pwd|exit"

# Disable suggestion for large buffers
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
