#!/bin/zsh

alias -g G='|grep'
alias -g L='|less'

alias reload_zshrc=". $HOME/.zshenv && echo 'Reloaded'"

# {{{ 'ls' aliases

# sorts by time change
alias l='ls'
# sorts by size
alias lk='ls -S'
# sorts by extension
alias lx='ls -X'

# }}}

# {{{ 'cd' aliases

alias .='ls'
alias ..='cd ..'
alias ...='cd ../..'
alias cd..='..'
alias cdu='cd-gitroot'

# }}}

# {{{ aliases just with additional parameters

alias mkdir='mkdir -pv'
alias grep='egrep -ai --color=auto'
alias dmesg='dmesg -L'
alias ping='ping -c 4 -v'
alias df='df -h'
alias du='du -ch'

# }}}

# {{{ just abbrevations

if is_command_present nvim; then
    alias vim='nvim'
fi

alias vp="vim -u $XDG_CONFIG_HOME/vim/vimrc.prose"
alias vc="vim -u $XDG_CONFIG_HOME/vim/vimrc.code"
alias rmd='rm -rf'
alias ta='tmux attach'
alias g='git'

# }}}

# {{{ k8s

if is_command_present kubectl; then
    alias k='kubectl'
fi

if is_command_present kubectx; then
    alias kctx='kubectx'
    alias kens='kubens'
fi

# }}}

if is_command_present mutt; then
    alias mutt="mutt -F $HOME/.config/mutt/muttrc"
fi

if is_command_present sudo; then
    alias svim="sudo $EDITOR"
    alias srm='sudo rm'
    alias srmd='sudo rm -rf'
    alias smv='sudo mv'
    alias smkd='sudo mkdir'
fi

if is_command_present bat; then
    alias cat="bat --decorations never"
fi

# {{{ common typos

alias ks='ls'
alias sl='ls'
alias :q='exit'
alias exti='exit'
alias quit='exit'

# }}}
