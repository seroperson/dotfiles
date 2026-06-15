#!/bin/zsh

_gitt_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/gitt-completion.zsh"
_gitt_bin="$(command -v gitt)"

if [[ ! -f "$_gitt_cache" || "$_gitt_bin" -nt "$_gitt_cache" ]]; then
  mkdir -p "${_gitt_cache:h}"
  command gitt completion zsh > "$_gitt_cache"
  zcompile -R "$_gitt_cache" 2>/dev/null
fi

source "$_gitt_cache"

unset _gitt_cache _gitt_bin
