#!/bin/zsh

export PATH="$PATH:$ZDOTDIR/bin"

# {{{ zgenom configuration

local zgenom_file=$XDG_DATA_HOME/zgenom/zgenom.zsh

if ! [ -e $zgenom_file ]; then
  git clone https://github.com/jandamm/zgenom.git $XDG_DATA_HOME/zgenom/
fi

# {{{ z configuration

_Z_DATA=$XDG_DATA_HOME/zsh_z
_Z_CMD=j

# }}}

export ZGEN_CUSTOM_COMPDUMP="$XDG_DATA_HOME/zcompdump_$ZSH_VERSION"

source $zgenom_file
if ! zgenom saved; then
  # lazy sourcing
  zgenom load romkatv/zsh-defer
  # change directory to git root
  zgenom load mollifier/cd-gitroot
  # the best theme ever
  zgenom load subnixr/minimal
  # jumping around (alternative to fasd)
  zgenom load rupa/z
  # zsh anything.el-like widget
  zgenom load zsh-users/zaw

  # Automatically starts ssh-agent
  if ! is_arg_present "$IS_PREVIEW"; then
    zgenom ohmyzsh plugins/ssh-agent
  fi

  # history-based autosuggestions
  zgenom load zsh-users/zsh-autosuggestions
  # autocomplete
  zgenom load marlonrichert/zsh-autocomplete
  # missing completions
  zgenom load zsh-users/zsh-completions
  zgenom load carlosedp/mill-zsh-completions

  zgenom compile $ZDOTDIR

  zgenom save
fi

# {{{ Theme configuration

MNML_MAGICENTER=(mnml_me_git)
MNML_USER_CHAR="$"
MNML_INSERT_CHAR=">"
MNML_NORMAL_CHAR="-"
MNML_ELLIPSIS_CHAR="..."
MNML_PROMPT=(mnml_status mnml_keymap)
MNML_RPROMPT=("mnml_cwd 2 256" mnml_git git_count_modified_files)

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

# {{{ Including sources

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
include_source "bindkey.zsh" "bindkey.$OS.zsh"

include_source "machine-based.zsh"
include_source "alias.zsh" "alias.$OS.zsh"

# {{{ Including soft-based configurations

is_tmux_enabled && source "$ZDOTDIR/soft/tmux.zsh"
is_command_present jj && zsh-defer -p source "$ZDOTDIR/soft/jj.zsh"

# Load autosuggestions config
source "$ZDOTDIR/soft/autosuggestions.zsh"

# }}}

# }}}

# {{{ History configuration

export HISTFILE="$XDG_DATA_HOME/zsh_history"
export HISTSIZE=2147483647 # LONG_MAX
export SAVEHIST=$HISTSIZE

HISTORY_IGNORE='(ls *|ls|cd *|cd|cdu|pwd|cat *|history|clear|cls|exit)'

zshaddhistory() {
  emulate -L zsh
  setopt extendedglob
  [[ $1 != ${~HISTORY_IGNORE} ]]
}

# }}}

# {{{ Other

rationalize_path path

# -p disables 'zle reset-prompt' call
zsh-defer -p init_gpg_key >&/dev/null

# Setup fnm
eval "$(fnm env --use-on-cd --shell zsh)"

# }}}
