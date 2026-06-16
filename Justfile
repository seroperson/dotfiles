# Recipes for managing this dotfiles flake.
# Run `just <recipe>` from anywhere inside the repo.

# list available recipes
default:
    @just --list

# update flake inputs (nixpkgs, home-manager, ...)
update:
    nix flake update

# rebuild + activate the Linux home-manager generation
switch-linux:
    home-manager switch --flake .#seroperson

# rebuild + activate the macOS (Apple Silicon) home-manager generation
switch-osx:
    home-manager switch --flake .#seroperson@darwin

# update flake inputs, then rebuild the Linux generation
update-linux: update switch-linux

# update flake inputs, then rebuild the macOS generation
update-osx: update switch-osx
