#!/bin/zsh

_jj_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/jj-completion.zsh"
_jj_bin="$(command -v jj)"

if [[ ! -f "$_jj_cache" || "$_jj_bin" -nt "$_jj_cache" ]]; then
  mkdir -p "${_jj_cache:h}"
  command jj util completion zsh > "$_jj_cache"
  zcompile -R "$_jj_cache" 2>/dev/null
fi

source "$_jj_cache"

unset _jj_cache _jj_bin
