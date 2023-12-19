#!/bin/zsh

# {{{ completion configuration
#     stackoverflow.com/questions/171563/whats-in-your-zshrc

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# have the newer files last so I see them first
zstyle ':completion:*' file-sort modification reverse
# egomaniac!
zstyle ':completion:*' list-separator 'fREW'
# don't complete directory we are already in (../here)
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' accept-exact '*(N)'
# don't prompt for a huge list, page it
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
# don't prompt for a huge list, menu it!
zstyle ':completion:*:default' menu 'select=0'
# separate man page sections. neat.
zstyle ':completion:*:manuals' separate-sections true
# complete with a menu for xwindow ids
zstyle ':completion:*:windows' menu on=0
zstyle ':completion:*:expand:*' tag-order all-expansions
# errors format
zstyle ':completion:*:corrections' format '%B%d (errors %e)%b'
# more errors allowed for large words and fewer for small words
zstyle ':completion:*:approximate:*' max-errors 'reply=(  $((  ($#PREFIX+$#SUFFIX)/3  ))  )'
zstyle ':completion::approximate*:*' prefix-needed false
# faster! (?)
zstyle ':completion::complete:*' use-cache 1
# don't complete stuff already on the line
zstyle ':completion::*:(rm|vi):*' ignore-line true

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
