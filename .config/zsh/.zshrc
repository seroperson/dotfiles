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
  # per-directory custom environment
  zgen load Tarrasch/zsh-autoenv
  # quickly go back to a specific parent directory instead of ../../..
  zgen load Tarrasch/zsh-bd
  # the best theme ever
  zgen load subnixr/minimal
  # jumping around (alternative to fasd)
  zgen load rupa/z
  # zsh anything.el-like widget
  zgen load zsh-users/zaw
  zgen save
fi

# {{{ theme configuration

# 'minimal' theme's redundant feature
MINIMAL_MAGIC_ENTER=""
MINIMAL_USER_CHAR="$"
MINIMAL_INSERT_CHAR=">"
MINIMAL_NORMAL_CHAR="-"
# overriding because i don't want to strip my path
function minimal_path {
  local w="%{\e[0m%}"
  local cwd="%2~"
  cwd="${(%)cwd}"
  cwd=("${(@s:/:)cwd}")
  echo "$_greyp${(j:/:)cwd//\//$w/$_greyp}$w"
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
