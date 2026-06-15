#!/bin/zsh

# History-only strategy; the `completion` fallback triggers completion
# machinery on every keystroke and is too expensive
ZSH_AUTOSUGGEST_STRATEGY=(history)

# Compute suggestions in a worker thread so typing latency stays flat
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Set the suggestion highlight style (default is underline)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8a8a8a,bold"

# Set buffer max size (increase if needed)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Only consider recent history entries more relevant
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *|ls *|pwd|exit"

# Disabling automatic widget re-binding
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
