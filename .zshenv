#!/bin/zsh

# {{{ xdg

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
# export LD_LIBRARY_PATH="/usr/lib/"

# managing zsh dot directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export PATH=$PATH:$HOME/.local/share/bin:$HOME/.local/bin:$HOME/.nix-profile/bin:/opt/cuda/bin:$HOME/.cargo/bin

# }}}

# {{{ language

export LANG=en_US.UTF-8

# Fixes weird WSL symbols
# https://github.com/microsoft/WSL/issues/4446
export LESSCHARSET="utf-8"


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
export PAGER="moor"
export BROWSER="chromium"
export EMAIL="seroperson@gmail.com"

# }}}

# {{{ other

export NIX_CONFIG="extra-experimental-features = nix-command flakes"

# don't create .lesshst
export LESSHISTFILE=-

# awesomewm filled window fix
export _JAVA_AWT_WM_NONREPARENTING=1
# JDK17 sbt warning fix
export JDK_JAVA_OPTIONS="--add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED --add-opens=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED --add-opens=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED --add-opens=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED --add-opens=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED"

# 'ls' coloring
export LS_COLORS="di=34;40:ln=35;40:so=32;40:pi=33;40:"

# }}}
