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
# `get_or_else $A $B`
get_or_else() {
  is_arg_present "$1" && echo "$1" || echo "$2"
}

# }}}

# {{{ 'is_*_(available|enabled)' functions

is_tmux_enabled() {
  is_command_present tmux
}
is_fasd_enabled() {
  is_command_present fasd
}

# }}}

# {{{ 'is_in_*' functions

is_in_x() {
  is_arg_present "$DISPLAY"
}
is_in_tmux() {
  is_arg_present "$TMUX"
}

# }}}

# {{{ init_* functions

init_ssh_key() {
    # TODO improve logic
    if ! is_arg_present "$IS_PREVIEW" && ! is_arg_present "$SSH_AUTH_SOCK"; then
        SSH_AUTH_SOCK=$(find /tmp/ -name "agent.*" -user $(whoami) -print -quit)
        if is_arg_present "$SSH_AUTH_SOCK"; then
            export SSH_AUTH_SOCK
            export SSH_AGENT_PID=$(($(echo $SSH_AUTH_SOCK | cut -d. -f2) + 1))
        else
            eval `ssh-agent -s`
            ssh-add "$SSH_KEY_PATH"
        fi
    fi
}

init_gpg_key() {
    if ! is_arg_present "$IS_PREVIEW"; then
      # kill -0 checks to see if the pid exists
      if test -f /tmp/gpg-agent-info && kill -0 $(cut -d: -f 2 /tmp/gpg-agent-info) 2>/dev/null; then
          GPG_AGENT_INFO=$(cat /tmp/gpg-agent-info | cut -c 16-)
      else
          # No, gpg-agent not available; start gpg-agent
          eval `gpg-agent --daemon --no-grab --write-env-file /tmp/gpg-agent-info`
      fi
      export GPG_TTY=$(tty)
      export GPG_AGENT_INFO
    fi
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

# quick search.
search() {
  find . -iname "*$1*"
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
  export OPENAI_API_KEY=`curl -L -X POST --silent 'https://ngw.devices.sberbank.ru:9443/api/v2/oauth' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json' -H 'RqUID: b1ddb72c-039f-4fae-ae32-ed3867b76b9d' -H "Authorization: Basic $SBER_API_KEY" --data-urlencode 'scope=GIGACHAT_API_PERS' --insecure | jq -r .access_token`
}

# https://www.joshyin.cc/blog/speeding-up-zsh
function timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do , time $shell -i -c exit; done
}

# }}}

