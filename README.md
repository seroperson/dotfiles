# ⚙️ seroperson's dotfiles

<div align="center">
<p>
  <a href="https://github.com/seroperson/dotfiles/pulse">
    <img alt="Last commit" src="https://img.shields.io/github/last-commit/seroperson/dotfiles?style=for-the-badge&logo=speedtest&color=8bd5ca&logoColor=D9E0EE&labelColor=302D41"/>
  </a>
  <a href="https://github.com/seroperson/dotfiles/blob/master/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/seroperson/dotfiles?style=for-the-badge&color=ee999f&logoColor=D9E0EE&labelColor=302D41" />
  </a>
  <a href="https://github.com/seroperson/dotfiles/stargazers">
    <img alt="Stars" src="https://img.shields.io/github/stars/seroperson/dotfiles?style=for-the-badge&logo=polestar&color=c69ff5&logoColor=D9E0EE&labelColor=302D41" />
  </a>
  <a href="https://seroperson.me/">
    <img alt="" src="https://img.shields.io/badge/seroperson.me-blue?label=website&style=for-the-badge&logo=starship&color=8aadf3&logoColor=D9E0EE&labelColor=302D41" />
  </a>
</p>
</div>

Configuration which I use for my daily development purposes.

## ✨ Features

- Installation and building is fully managed by `nix`.
- Powered by [jandamm/zgenom][19] plugin manager (see `zsh/.zshrc` for all used plugins) lightweight `zsh` shell.
- [subnixr/minimal][16] theme.
- [rupa/z][18] to jump around most used directories (mapped to `j` command).
- Automatically starts `tmux` using predefined `tmuxinator` config.
- Automatically inits `gpg` and `ssh-agent` sessions.
- Store sensitive settings under untracked `zsh/machine-based.zsh` file.
- Comes with many development utils, like [exa][2], [rg][4], [jq][3], [yq][11], [ouch][12] (see `home.nix` for complete list).
- [nix-community/comma][17] to run software without installation (like `, tree` to download and run `tree`).
- Customized [AstroNvim][1] community distribution.

Some overview is also available in my article [⚙️ Managing dotfiles with Nix][20].

## 📲 Preview without installation

<p align="center">
  <img src="doc/docker.gif" alt="Preview using docker" width="700px">
</p>

To try this configuration, you can either start it in Docker container or using `nix develop` shell:

<details>
<summary>Docker</summary>

```sh
nix build github:seroperson/dotfiles#docker
docker load < ./result
docker run --rm -it seroperson.me/dotfiles
```

</details>

<details>
<summary>nix develop</summary>

You'll also need to redefine your `HOME` and `USER` environment variables:

```sh
mkdir -p /tmp/test
USER=seroperson-preview HOME=/tmp/test nix develop --impure github:seroperson/dotfiles
```

</details>

## 🚀 Installation

Initially, only `nix` and `git` must be installed. Be sure that nix is up-to-date:

```sh
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
```

Clone the repository:

```sh
git clone https://github.com/seroperson/dotfiles $HOME/.dotfiles/
```

And then let the `home-manager` do the rest:

```sh
home-manager init --switch $HOME/.dotfiles/ --flake $HOME/.dotfiles/
```

or using `nix`, if `home-manager` is unavailable:

```sh
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
nix run github:nix-community/home-manager -- init --switch $HOME/.dotfiles/ --flake $HOME/.dotfiles/
```

Next, you should do `chsh $USER -s $HOME/.nix-profile/bin/zsh` and re-login.

Finally, be sure to install [Nerd Font][14] and [Catpuccin theme][15] (`mocha` variant) for your terminal.

## 📦 Update packages

In order to update installed packages, use the following commands:

```sh
nix-channel --update
nix-env -u --always
nix flake update
```

And then re-init `home-manager` with command from section above.

## 🚦 Troubleshooting

Usually nix doesn't work as expected and you don't know what to do.
It is good idea to start your troubleshooting with global cleanup:

```sh
nix-channel --update
nix-env -u --always
rm /nix/var/nix/gcroots/auto/*
rm -rf $HOME/.cache/nix
nix-collect-garbage -d
```

Also it's possible to debug nix variables using `nix repl`. For example, to
load flake into repl, you can do the following:

```sh
nix repl

nix-repl> :lf ./
nix-repl> builtins.attrNames homeConfigurations.seroperson
```

## 📂 Nix Guides

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
[11]: https://github.com/mikefarah/yq
[12]: https://github.com/ouch-org/ouch
[13]: https://github.com/marlonrichert/zsh-autocomplete
[14]: https://github.com/ryanoasis/nerd-fonts
[15]: https://github.com/catppuccin
[16]: https://github.com/subnixr/minimal
[17]: https://github.com/nix-community/comma
[18]: https://github.com/rupa/z
[19]: https://github.com/jandamm/zgenom
[20]: https://seroperson.me/2024/01/16/managing-dotfiles-with-nix/
