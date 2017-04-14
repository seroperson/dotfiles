#!/bin/zsh

# {{{ vi mode

bindkey -v
# reduce <esc> waiting
export KEYTIMEOUT=1

# }}}

# {{{ c-s inserts "sudo " at the start of line

function insert_sudo () {
    zle beginning-of-line
    zle -U "sudo "
}
zle -N insert-sudo insert_sudo
bindkey "^s" insert-sudo

# }}}

# {{{ bind ^c to change mode to normal

bindkey -M viins '^c' vi-cmd-mode

# }}}

# {{{ do 'git status --short' when 'enter' was pressed in git repo

function do_enter() {
    if [ -n "$BUFFER" ]; then
        zle accept-line
        return 0
    fi
    echo
    if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
        git st
    fi
    zle reset-prompt
    return 0
}
zle -N do_enter
bindkey '^m' do_enter

# }}}

# {{{ c-r starts searching history backward

bindkey '^r' history-incremental-search-backward

# }}}

# {{{ allow c-k, c-j to navigate history (standard behaviour)

bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

# }}}
