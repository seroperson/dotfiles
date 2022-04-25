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

is_base16_shell_available() {
  file_exists "$BASE16_SHELL_DIRECTORY"
}
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

# {{{ base16 functions

enable_base16_shell() {
    local theme_name=$(get_or_else "$1" "$BASE16_THEME_NAME")
    if is_arg_present "$theme_name"; then
        local path_prefix="$BASE16_SHELL_DIRECTORY/base16-"
        local theme_prefix=$(get_or_else "$2" "$BASE16_THEME_PREFIX")
        local theme_path="$path_prefix`echo $theme_name$(is_arg_present \"$theme_prefix\" && echo "-$theme_prefix")`.sh"
        if ! file_exists "$theme_path"; then
            theme_path="$path_prefix$theme_name.sh"
        fi
        if file_exists "$theme_path"; then
            export BASE16_THEME_NAME=$theme_name
            export BASE16_THEME_PREFIX=$theme_prefix
            . $theme_path
        else
            echo "Seems like the theme $theme_path isn't exists"
            false
        fi
    else
        echo "You shold pass first argument or set \$BASE16_THEME_NAME env variable"
        false
    fi
}

# todo: 'autocomplete' stuff?
list_base16_shell_themes() {
  ls "$BASE16_SHELL_DIRECTORY" | grep ".sh"
}

# }}}

# {{{ init_* functions

init_ssh_key() {
    # TODO improve logic
    if [ -z "$SSH_AUTH_SOCK" ]; then
        SSH_AUTH_SOCK=$(find /tmp/ -name "agent.*" -user $(whoami) -print -quit)
        if [ "x$SSH_AUTH_SOCK" != "x" ]; then
            export SSH_AUTH_SOCK
            export SSH_AGENT_PID=$(($(echo $SSH_AUTH_SOCK | cut -d. -f2) + 1))
        else
            eval `ssh-agent -s`
            ssh-add "$SSH_KEY_PATH"
        fi
    fi
}

init_gpg_key() {
    # kill -0 checks to see if the pid exists
    if test -f /tmp/gpg-agent-info && kill -0 $(cut -d: -f 2 /tmp/gpg-agent-info) 2>/dev/null; then
        GPG_AGENT_INFO=$(cat /tmp/gpg-agent-info | cut -c 16-)
    else
        # No, gpg-agent not available; start gpg-agent
        eval `gpg-agent --daemon --no-grab --write-env-file /tmp/gpg-agent-info`
    fi
    export GPG_TTY=$(tty)
    export GPG_AGENT_INFO
}

# }}}

# {{{ android

capture_png() {
  local name
  local device
  local is_emu=false
  while getopts "is:eo:" option; do
    case $option in
      i) read name\?"Enter the path: " ;;
      s) device=$OPTARG ;;
      e) is_emu=true ;;
      o) name=$OPTARG ;;
    esac
  done
  if [ "x$name" = "x" ]; then # fallback if there is no input
    name="`pwd`/screen-`date "+%d-%m-%Y-%H-%M-%S"`.png"
  fi
  eval name="$name" # expand path
  local adb_switches
  if [ "$is_emu" = true ]; then
    adb_switches+=" -e"
  elif [ "x$device" != "x" ]; then
    adb_switches+=" -s $device"
  fi
  set -o pipefail
  eval adb $adb_switches shell screencap -p | perl -pe 's/\x0D\x0A/\x0A/g' > $name
  local result=$?
  if [ $result -eq 0 ]; then
    echo "Successfully saved to $name"
  else
    rm $name # todo: wtf
    return $result
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

# }}}

