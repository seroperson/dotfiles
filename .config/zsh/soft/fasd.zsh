#!/bin/zsh
# github.com/clvv/fasd

export _FASD_DATA="$XDG_DATA_HOME/fasd"

fasd_cache="$XDG_CACHE_HOME/fasd_cache"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
    fasd --init zsh-hook zsh-ccomp zsh-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

# function to execute built-in cd
fasd_cd() {
    if [ $# -le 1 ]; then
        fasd "$@"
    else
        local _fasd_ret="$(fasd -e 'printf %s' "$@")"
        [ -z "$_fasd_ret" ] && return
        [ -d "$_fasd_ret" ] && cd "$_fasd_ret" || printf %s\\n "$_fasd_ret"
    fi
}

alias j='fasd_cd -d'
alias jj='j -li'
