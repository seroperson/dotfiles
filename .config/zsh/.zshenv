#!/bin/zsh

# {{{ xdg

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# managing zsh dot directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export PATH=$PATH:$HOME/.local/share/bin:$HOME/.local/bin:$HOME/.nix-profile/bin:/opt/cuda/bin

# }}}

# {{{ language

export LANG=en_US.UTF-8

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

export EDITOR="nvim"
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

# }}}
