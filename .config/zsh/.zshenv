#!/bin/zsh

# {{{ xdg

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# make vim honor my .config directory
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

# managing zsh dot directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ADOTDIR="$XDG_CACHE_HOME/antigen"

export PATH=$PATH:$HOME/.local/share/bin

# }}}

# {{{ language

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# }}}

# {{{ history

export HISTFILE="$XDG_DATA_HOME/zsh_history"
export HISTSIZE=65536
export SAVEHIST=$HISTSIZE

# }}}

# {{{ typeset
#     read more at:
#     * linux-mag.com/id/1079/
#     * zsh.sourceforge.net/Guide/zshguide03.html

# preserve just only unique path entries
typeset -U path

typeset -TU SBT_OPTS sbt_opts " "
sbt_opts=("-Xmx4096M"\
    "-XX:MaxPermSize=4G")

typeset -TU _JAVA_OPTIONS java_opts " "
java_opts=("-XX:+OptimizeStringConcat" \
    "-XX:+CMSClassUnloadingEnabled" \
    "-XX:+UseConcMarkSweepGC" \
    "-XX:+AggressiveOpts" \
    "-XX:+UseBiasedLocking" \
    "-XX:+DisableExplicitGC " \
    "-XX:+HeapDumpOnOutOfMemoryError" \
    "-XX:MaxJavaStackTraceDepth=-1" \
    "-Xquickstart" \
    # don't keep my intellij file history
    "-DlocalHistory.daysToKeep=0" \
    "-Dawt.useSystemAAFontSettings=lcd" \
    "-Dsun.java2d.xrender=true" \
    "-Dsun.io.useCanonCaches=false" \
    "-Djava.net.preferIPv4Stack=true" \
    "-ea")

# }}}

# {{{ identity

export EDITOR="vim"
export VISUAL=$EDITOR
export PAGER="less -FX"
export BROWSER="chromium"
export EMAIL="seroperson@gmail.com"

# }}}

# {{{ other

# don't create .lesshst
export LESSHISTFILE=-

# awesomewm filled window fix
export _JAVA_AWT_WM_NONREPARENTING=1

# 'ls' coloring
export LS_COLORS="di=34;40:ln=35;40:so=32;40:pi=33;40:"

# if you would to enable base16, just clone the repository into .. of directory below
export BASE16_SHELL_DIRECTORY="$XDG_CONFIG_HOME/base16/base16-shell/scripts/"

# }}}
