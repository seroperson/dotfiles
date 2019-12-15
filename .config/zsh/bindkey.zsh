#!/bin/zsh

# {{{ vi mode

bindkey -v
# reduce <esc> waiting
export KEYTIMEOUT=1

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

# {{{ bind c-j to go to ..

function cd_up () {
    zle push-line
    LBUFFER='cd ..'
    zle accept-line
}

zle -N cd_up

bindkey '^j' cd_up

# }}}

# {{{ zaw configuration

bindkey '^g' zaw-git-recent-branches

bindkey '^r' zaw-history
bindkey -M filterselect '^r' down-line-or-history
bindkey -M filterselect '^j' down-line-or-history
bindkey -M filterselect '^k' up-line-or-history
bindkey -M filterselect '^t' accept-search

# }}}
