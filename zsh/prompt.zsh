#!/bin/zsh

# right-prompt segment that shows the active git authorship profile in git repos
# profiles are discovered from GAUTH_<KEY>_EMAIL env vars (see `gauth` in func.zsh)
mnml_gauth() {
  local email
  email="$(command git config --get user.email 2>/dev/null)" || return
  [ -z "$email" ] && return
  local var key color_var color
  for var in ${(M)${(k)parameters}:#GAUTH_*_EMAIL}; do
    if [ "${(P)var}" = "$email" ]; then
      key="${${var#GAUTH_}%_EMAIL}"
      color_var="GAUTH_${key}_COLOR"
      color="${(P)color_var:-cyan}"
      print -n "%F{${color}}@${(L)key}%f"
      return
    fi
  done
  print -n "%F{yellow}@${email%%@*}%f"
}

# zimfw's `minimal` theme hardcodes RPS1; prepend our segment to it
RPS1='$(mnml_gauth) '"$RPS1"
