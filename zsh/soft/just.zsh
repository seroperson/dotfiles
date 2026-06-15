#!/bin/zsh

_just_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/just-completion.zsh"
_just_bin="$(command -v just)"

if [[ ! -f "$_just_cache" || "$_just_bin" -nt "$_just_cache" ]]; then
  mkdir -p "${_just_cache:h}"
  command just --completions zsh > "$_just_cache"
  zcompile -R "$_just_cache" 2>/dev/null
fi

source "$_just_cache"

unset _just_cache _just_bin
