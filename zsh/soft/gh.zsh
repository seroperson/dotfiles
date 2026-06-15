#!/bin/zsh

_gh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/gh-completion.zsh"
_gh_bin="$(command -v gh)"

if [[ ! -f "$_gh_cache" || "$_gh_bin" -nt "$_gh_cache" ]]; then
  mkdir -p "${_gh_cache:h}"
  command gh completion -s zsh > "$_gh_cache"
  zcompile -R "$_gh_cache" 2>/dev/null
fi

source "$_gh_cache"

unset _gh_cache _gh_bin
