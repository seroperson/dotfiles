#!/bin/zsh

_alw_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/alw-completion.zsh"
_alw_bin="$(command -v alw)"

if [[ ! -f "$_alw_cache" || "$_alw_bin" -nt "$_alw_cache" ]]; then
  mkdir -p "${_alw_cache:h}"
  command alw completion zsh > "$_alw_cache"
fi

source "$_alw_cache"

unset _alw_cache _alw_bin
