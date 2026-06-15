#!/bin/zsh

# Load home-manager session variables (e.g. LD_LIBRARY_PATH)
[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

export PATH="$PATH:$ZDOTDIR/bin"

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


# {{{ z configuration

_Z_DATA=$XDG_DATA_HOME/zsh_z
_Z_CMD=j

# }}}

# {{{ zimfw configuration

ZIM_HOME=$XDG_DATA_HOME/zim

# Download zimfw plugin manager if missing
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

source ${ZIM_HOME}/init.zsh

# Defer-source plugins we don't need on the first prompt (saves ~13ms sync)
# zaw widgets are bound in bindkey.zsh and only
# resolve at key-press time, so the binding survives the deferred load.
# fpath + autoload still need to happen synchronously so zaw's autoloaded
# functions resolve when its source eventually runs
fpath=("${ZIM_HOME}/modules/zaw/functions" $fpath)
autoload -Uz filter-select fill-vars-or-accept
zsh-defer source "${ZIM_HOME}/modules/zaw/zaw.zsh"
# Bindings into zaw's filterselect keymap have to happen after the source above
zsh-defer bindkey -M filterselect '^r' down-line-or-history
zsh-defer bindkey -M filterselect '^j' down-line-or-history
zsh-defer bindkey -M filterselect '^k' up-line-or-history
zsh-defer bindkey -M filterselect '^t' accept-search

# }}}

# {{{ Including sources

include_source "opt.zsh" "opt.$OS.zsh"
include_source "zstyle.zsh" "zstyle.$OS.zsh"
include_source "bindkey.zsh" "bindkey.$OS.zsh"
include_source "prompt.zsh"

include_source "machine-based.zsh"
include_source "alias.zsh" "alias.$OS.zsh"

# {{{ Including soft-based configurations

is_tmux_enabled && source "$ZDOTDIR/soft/tmux.zsh"
is_command_present jj && zsh-defer -p source "$ZDOTDIR/soft/jj.zsh"
is_command_present alw && zsh-defer -p source "$ZDOTDIR/soft/alw.zsh"
is_command_present gitt && zsh-defer -p source "$ZDOTDIR/soft/gitt.zsh"
is_command_present just && zsh-defer -p source "$ZDOTDIR/soft/just.zsh"
is_command_present kubectl && zsh-defer -p source "$ZDOTDIR/soft/kubectl.zsh"
is_command_present gh && zsh-defer -p source "$ZDOTDIR/soft/gh.zsh"

# Load autosuggestions config
source "$ZDOTDIR/soft/autosuggestions.zsh"

# }}}

# }}}

# {{{ History configuration

export HISTFILE="$XDG_DATA_HOME/zsh_history"
export HISTSIZE=2147483647 # LONG_MAX
export SAVEHIST=$HISTSIZE

HISTORY_IGNORE='(ls|cd|cdu|pwd|history|clear|cls|exit)'

zshaddhistory() {
  emulate -L zsh
  setopt extendedglob
  [[ $1 != ${~HISTORY_IGNORE} ]]
}

# }}}

# {{{ Other

source "$ZDOTDIR/python.zsh"

rationalize_path path

# -p disables 'zle reset-prompt' call
zsh-defer -p init_gpg_key >&/dev/null

# WSL proxy auto-enable - body is cache-only now, the slow host detection
# runs in a detached background job (see __wsl_host_fast in proxy.zsh)
zsh-defer _proxy_auto_enable

# Setup fnm
zsh-defer -c 'eval "$(fnm env --use-on-cd --shell zsh)"'

# rbenv init
zsh-defer -c 'eval "$(rbenv init - --no-rehash zsh)"'

# }}}
