#!/bin/zsh

# right-prompt segment that shows the active git authorship profile in git repos
# profiles are discovered from GAUTH_<KEY>_EMAIL env vars (see `gauth` in func.zsh)

# memoize the email->key and key->color maps so we don't scan (k)parameters per prompt
typeset -gA _GAUTH_EMAIL_MAP _GAUTH_COLOR_MAP
typeset -g _GAUTH_MAP_BUILT

_gauth_build_map() {
  local var key color_var
  _GAUTH_EMAIL_MAP=()
  _GAUTH_COLOR_MAP=()
  for var in ${(M)${(k)parameters}:#GAUTH_*_EMAIL}; do
    key="${${var#GAUTH_}%_EMAIL}"
    _GAUTH_EMAIL_MAP[${(P)var}]="$key"
    color_var="GAUTH_${key}_COLOR"
    _GAUTH_COLOR_MAP[$key]="${(P)color_var:-cyan}"
  done
  _GAUTH_MAP_BUILT=1
}

mnml_gauth() {
  local email
  email="$(command git config --get user.email 2>/dev/null)" || return
  [ -z "$email" ] && return
  [ -z "$_GAUTH_MAP_BUILT" ] && _gauth_build_map
  local key="${_GAUTH_EMAIL_MAP[$email]}"
  if [ -n "$key" ]; then
    print -n "%F{${_GAUTH_COLOR_MAP[$key]}}@${(L)key}%f"
  else
    print -n "%F{yellow}@${email%%@*}%f"
  fi
}

# zimfw's `minimal` theme hardcodes RPS1; prepend our segment to it
RPS1='$(mnml_gauth) '"$RPS1"
