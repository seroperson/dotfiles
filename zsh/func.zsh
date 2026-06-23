#!/bin/sh

# {{{ common

# if file_exists file; then
file_exists() {
  [ -e "$1" ]
}
# if is_command_present abc; then
is_command_present() {
  command -v "$1" > /dev/null 2>&1
}
# if arg_is_present $A; then
is_arg_present() {
  [ "x$1" != "x" ]
}
# }}}

# {{{ 'is_*_(available|enabled)' functions

is_tmux_enabled() {
  is_command_present tmux
}

# }}}

# {{{ 'is_in_*' functions

is_in_tmux() {
  is_arg_present "$TMUX"
}

# }}}

# {{{ other

# removes nonexistent directories from an array
#   zsh.sourceforge.net/Contrib/startup/users/debbiep/dot.zshenv
rationalize_path () {
    local element
    local build
    build=()
    eval '
    foreach element in "$'"$1"'[@]"
    do
        if [[ -d "$element" ]]
        then
            build=("$build[@]" "$element")
        fi
    done
    '"$1"'=( "$build[@]" )
    '
}

# quick search by filename substring
ffind() {
  find . -iname "*$1*"
}

# writes the active gh token into ~/.config/nix/extra.conf so flake
# fetches use the authenticated GitHub rate limit (5000/hr vs 60/hr)
# re-run after `gh auth switch` or when the token rotates
nix-refresh-token() {
  if ! is_command_present gh; then
    echo "nix-refresh-token: gh not installed" >&2
    return 1
  fi
  local token
  token="$(gh auth token 2>/dev/null)"
  if [ -z "$token" ]; then
    echo "nix-refresh-token: not authenticated (run \`gh auth login\`)" >&2
    return 1
  fi
  mkdir -p "$HOME/.config/nix"
  print -r -- "access-tokens = github.com=$token" > "$HOME/.config/nix/extra.conf"
  chmod 600 "$HOME/.config/nix/extra.conf"
  echo "nix-refresh-token: wrote $HOME/.config/nix/extra.conf"
}

# kills anyone who is using the given port
#   github.com/kevinSuttle/dotfiles/commit/9458141f40094d96952adc7c423cbdddeb909a81#commitcomment-4953601
free_port() {
  if ! is_arg_present "$1"; then
    echo "Usage: free_port [numeric port identifier]" >&2
    return 1
  fi
  lsof -i TCP:$1 | awk '/LISTEN/{print $2}' | xargs kill -9
}

# reloads sber GigaChat token using SBER_API_KEY variable
reload_gigachat_api_token() {
  export OPENAI_API_KEY=`curl -L -X POST --silent 'https://ngw.devices.sberbank.ru:9443/api/v2/oauth' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json' -H 'RqUID: b1ddb72c-039f-4fae-ae32-ed3867b76b9d' -H "Authorization: Basic $SBER_API_KEY" --data-urlencode 'scope=GIGACHAT_API_PERS' | jq -r .access_token`
}

# https://www.joshyin.cc/blog/speeding-up-zsh
function timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do , time $shell -i -c exit; done
}

# switches local git authorship and gpg signing for the current repo
# profiles come from GAUTH_<KEY>_{NAME,EMAIL,GH_USER,SSH_KEY,SIGN,ALIASES} env vars
# `gauth` prints current author, `gauth <profile>` switches
gauth() {
  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "gauth: not a git repository" >&2
    return 1
  fi

  # discover available profiles from GAUTH_*_EMAIL env vars
  local -a profiles
  local var
  for var in ${(M)${(k)parameters}:#GAUTH_*_EMAIL}; do
    profiles+=("${${var#GAUTH_}%_EMAIL}")
  done

  local key name email sign
  case "$1" in
    "") ;;
    -h|--help)
      echo "usage: gauth [${(j:|:)${(L)profiles}}]" >&2
      return 0
      ;;
    *)
      # match argument against profile names or aliases (case-insensitive)
      local arg="${(U)1}" candidate alias_var
      for candidate in $profiles; do
        if [ "$candidate" = "$arg" ]; then
          key="$candidate"; break
        fi
        alias_var="GAUTH_${candidate}_ALIASES"
        if [[ " ${(L)${(P)alias_var}} " == *" ${(L)1} "* ]]; then
          key="$candidate"; break
        fi
      done
      if [ -z "$key" ]; then
        echo "gauth: unknown profile '$1' (try: ${(j:, :)${(L)profiles}})" >&2
        return 1
      fi
      ;;
  esac
  if [ -n "$key" ]; then
    local var_name="GAUTH_${key}_NAME" var_email="GAUTH_${key}_EMAIL" var_gh="GAUTH_${key}_GH_USER" var_ssh="GAUTH_${key}_SSH_KEY" var_sign="GAUTH_${key}_SIGN"
    name="${(P)var_name}"
    email="${(P)var_email}"
    local gh_user="${(P)var_gh}"
    local ssh_key="${(P)var_ssh}"
    sign="${(P)var_sign:-true}"
    if [ -z "$name" ] || [ -z "$email" ]; then
      echo "gauth: $var_name / $var_email not set (machine-based.zshenv)" >&2
      return 1
    fi
    git config user.name "$name"
    git config user.email "$email"
    git config commit.gpgsign "$sign"
    if [ -n "$ssh_key" ]; then
      git config core.sshCommand "ssh -i ${ssh_key} -o IdentitiesOnly=yes -o ControlPath=$HOME/.ssh/agent/cm-%C-${ssh_key:t}"
    else
      git config --unset core.sshCommand 2>/dev/null
    fi
    if [ -n "$gh_user" ] && is_command_present gh; then
      gh auth switch -u "$gh_user" 2>&1 | sed 's/^/gauth: gh: /' >&2
    fi
  fi
  [ "$(git config commit.gpgsign)" = "true" ] && sign=" [signed]" || sign=" [unsigned]"
  local gh_active=""
  if is_command_present gh; then
    gh_active="$(gh auth status --active 2>/dev/null | awk '/Logged in to .* account/ {print $7; exit}')"
    [ -n "$gh_active" ] && gh_active=" gh:$gh_active"
  fi
  local ssh_info=""
  local current_ssh="$(git config core.sshCommand)"
  if [ -n "$current_ssh" ]; then
    ssh_info=" ssh:$(echo "$current_ssh" | grep -oE '\-i [^ ]+' | awk '{print $2}')"
  fi
  printf "%s <%s>%s%s%s\n" \
    "$(git config user.name)" \
    "$(git config user.email)" \
    "$sign" \
    "$gh_active" \
    "$ssh_info"
}

# wraps git so `git co <branch>` cd's into an existing worktree for that branch
# (git aliases run in a subshell and cannot change the parent shell's cwd, so the
# behavior lives here while `co` and `wt-path` stay declared in git/config)
git() {
  if [ "$1" = "co" ] && [ -n "$2" ] && [ "${2#-}" = "$2" ]; then
    local wt
    wt="$(command git wt-path "$2" 2>/dev/null)"
    if [ -n "$wt" ] && [ -d "$wt" ]; then
      cd -- "$wt"
      return
    fi
    if [ -n "$wt" ]; then
      # porcelain claims a worktree at $wt but the directory is gone (e.g. a
      # locked --lock worktree under /tmp that got wiped - lock survives prune).
      # release it so the branch becomes checkout-able in place
      command git worktree unlock "$wt" 2>/dev/null
      command git worktree remove --force "$wt" 2>/dev/null
    fi
    # plus drop any plain-prunable entries holding the branch
    command git worktree prune 2>/dev/null
  fi
  command git "$@"
}

# }}}

