#!/bin/zsh

# {{{ zsh-autocomplete configuration

# The max number of lines shown
zstyle ':autocomplete:*:*' list-lines 10

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
