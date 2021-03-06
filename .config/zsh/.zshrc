#!/bin/zsh

# {{{ zgen configuration

local zgen_file=$ZDOTDIR/zgen/zgen.zsh

if ! [ -e $zgen_file ]; then
  git clone https://github.com/tarjoilija/zgen.git $ZDOTDIR/zgen/
fi

# {{{ z configuration

_Z_DATA=$XDG_DATA_HOME/zsh_z
_Z_CMD=j

# }}}

source $zgen_file
if ! zgen saved; then
  # change directory to git repository root directory
  zgen load mollifier/cd-gitroot
  # the best theme ever
  zgen load subnixr/minimal
  # jumping around (alternative to fasd)
  zgen load rupa/z
  # zsh anything.el-like widget
  zgen load zsh-users/zaw
  zgen save
fi

# {{{ theme configuration

MNML_MAGICENTER=(mnml_me_git)
MNML_USER_CHAR="$"
MNML_INSERT_CHAR=">"
MNML_NORMAL_CHAR="-"
MNML_ELLIPSIS_CHAR="..."
MNML_RPROMPT=('mnml_cwd 2 256' mnml_git git_count_modified_files)

function git_count_modified_files() {
  local has_git="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
  if [ -n "$has_git" ]; then
    local count=$(git diff --numstat)
    if [ "x$count" != "x" ]; then
      echo $count | awk "{add+=\$1; del+=\$2} END {printf \"%%{\\033[3${MNML_OK_COLOR}m%%}+%s %%{\\033[3${MNML_ERR_COLOR}m%%}-%s%%{\\033[0m%%}\", add, del}"
    fi
  fi
}

# }}}

# }}}

# {{{ including sources

case `uname` in
  'Linux') OS='lin' ;;
  'Darwin') OS='osx' ;;
  'FreeBSD') OS='bsd' ;;
  *) OS='unk' ;;
esac

include_source() {
  [ -f "$ZDOTDIR/$1" ] && source "$ZDOTDIR/$1"
  [ "x$2" != "x" ] && include_source $2
}

include_source "func.zsh" "func.$OS.zsh"
include_source "opt.zsh" "opt.$OS.zsh"
include_source "zstyle.zsh" "zstyle.$OS.zsh"
include_source "alias.zsh" "alias.$OS.zsh"
include_source "bindkey.zsh" "bindkey.$OS.zsh"

# {{{ including soft-based configurations

is_base16_shell_available && source "$ZDOTDIR/soft/base16.zsh"
is_tmux_enabled && source "$ZDOTDIR/soft/tmux.zsh"

# }}}

include_source "machine-based.zsh"

# }}}

rationalize_path path

init_ssh_key >&/dev/null
init_gpg_key >&/dev/null
