#!/bin/zsh

# {{{ zsh-autocomplete configuration

# The max number of lines shown
zstyle ':autocomplete:*:*' list-lines 10

# Debounce before firing completion (default 0.05s feels laggy when typing fast).
zstyle ':autocomplete:*' delay 0.15

# Don't complete an empty line (listing all of $PATH is slow, rarely useful).
zstyle ':autocomplete:*' min-input 1

# Kill slow async completions fast (default 1.0s); network completers (kubectl,
# gh) or huge repos would otherwise hang the prompt. Slow ones just won't show.
zstyle ':autocomplete:*' timeout 0.5

# Skip compaudit (-C) - we trust nix-managed completion paths; saves ~11ms at startup
zstyle ':autocomplete::compinit' arguments -C

# Disable the recent-dirs feature (saves ~5ms at first prompt)
zstyle ':autocomplete:*' recent-dirs no

# }}}


# {{{ zaw configuration
#     github.com/zsh-users/zaw#key-binds-and-styles

zstyle ':filter-select:highlight' matched fg=blue
zstyle ':filter-select' max-lines 10
# enable case-insensitive
zstyle ':filter-select' case-insensitive yes
# ignore duplicates in history source
zstyle ':filter-select' hist-find-no-dups yes
# enable rotation for filter-select
zstyle ':filter-select' rotate-list yes

# }}}
