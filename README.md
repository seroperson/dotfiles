# seroperson's dotfiles

Configuration which I use for my development purposes. Not so recently I migrated all the dotfiles 
management to `nix` and it's still WIP, but mostly should work ok.

## Used software

Mostly I use well-known things:

* **zsh** - powered by `zgenom` plugin manager, lightweight shell.
* **nvim** - initially I used self-written config, but then switched to [astronvim][1] community distribution
  as long as managing well-prepared nvim configuration is a pretty hard task as for today. 
* **tmux** - terminal multiplexer, configuration managed by `nix` (see `nix/tmux.nix` file).

And also some set of handy tools, such as [exa][2], [jq][3], [rg][4].

## Installation

Initially, only `nix` and `git` must be installed. Be sure that nix is up-to-date:

```sh
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --updae
```

Clone the repository:

```sh
git clone https://github.com/seroperson/dotfiles $HOME/.dotfiles/
```

And then let the `home-manager` do the rest:

```sh
nix --extra-experimental-features "nix-command flakes" run home-manager/release-23.11 -- init --switch $HOME/.dotfiles/
```

Next, you should do `chsh $USER $HOME/.nix-profile/bin/zsh` and re-login.

Finally, be sure to install nerd-font and catpuccin mocha theme for your terminal.

## Troubleshooting

Usually nix doesn't work as expected and you don't know what to do. 
It is good idea to start your troubleshooting with global cleanup:

```sh
nix-channel --update
nix-env -u --always
rm /nix/var/nix/gcroots/auto/*
rm -rf $HOME/.cache/nix
nix-collect-garbage -d
```

## Nix Guides

`nix` is not easy thing to get started with, but luckily it has a lot of guides available across the web.
Here are some of them: 

- [Scrive Nix Workshop][7]
- [Introduction to Flakes][5]
- [Packaging software with Nix][10]
- [Home Manager Configuration Options][9]
- [Home Manager modules/][8]
- [Shebang Scripts in Nix Derivations][6]

[1]: https://astronvim.com/
[2]: https://github.com/ogham/exa
[3]: https://github.com/jqlang/jq
[4]: https://github.com/BurntSushi/ripgrep
[5]: https://nixos-and-flakes.thiscute.world/nixos-with-flakes/introduction-to-flakes
[6]: https://gist.github.com/CMCDragonkai/e82bce7bea30e28ebe6796025aa9e722
[7]: https://scrive.github.io/nix-workshop/index.html
[8]: https://github.com/nix-community/home-manager/tree/master/modules
[9]: https://nix-community.github.io/home-manager/options.xhtml
[10]: https://docs.replit.com/tutorials/replit/nix-packaging

