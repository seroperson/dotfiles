#!/bin/zsh

_kubectl_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/kubectl-completion.zsh"
_kubectl_bin="$(command -v kubectl)"

if [[ ! -f "$_kubectl_cache" || "$_kubectl_bin" -nt "$_kubectl_cache" ]]; then
  mkdir -p "${_kubectl_cache:h}"
  command kubectl completion zsh > "$_kubectl_cache"
  zcompile -R "$_kubectl_cache" 2>/dev/null
fi

source "$_kubectl_cache"

unset _kubectl_cache _kubectl_bin
