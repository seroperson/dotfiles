#!/bin/zsh

# ZDOTDIR is inherited by child shells, causing them to look here
# instead of ~/.zshenv - so forward to the actual file
source "$HOME/.zshenv"
