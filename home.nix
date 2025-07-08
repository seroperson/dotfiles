{ config
, pkgs
, useSymlinks
, homeDirectory
, username
, dotfilesDirectory
, ...
}:
let
  inherit (import ./nix/utils.nix { inherit config useSymlinks dotfilesDirectory; })
    fileReference;
in
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "yandex-cloud"
    ];

  imports = [
    ./nix/tmux.nix
  ];

  home = {
    inherit homeDirectory username;
    stateVersion = "24.05";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs.unstable; [
    # Shell and tools
    git
    zsh
    tmux
    tmuxinator
    ripgrep # Searching file content
    jq # Json manipulation
    yq # Yaml manipulation
    fd # Enhanced find
    bat # Enhanced cat
    eza # Enhanced ls
    ouch # Universal archiver
    wsl-open
    aider-chat # AI Assistant
    comma # Runs programs without installing them
    nix-index
    delta
    concurrently
    jujutsu # Git-compatible DVCS that is both simple and powerful
    dua # Disk usage
    htop

    # using unwrapped nvim allows you to easily use it outside of NixOS
    neovim-unwrapped

    # nvim dependencies
    pkgs.curl
    pkgs.unzip
    pkgs.gzip
    pkgs.gcc
    pkgs.gnutar
    pkgs.gnumake
    pkgs.iconv
    pkgs.tree-sitter
    pkgs.cargo

    # pekingese control
    kubectl
    kubevpn
    kubernetes-helm
    fluxcd
    sops
    postgresql_16
    awscli2
    yandex-cloud

    # Java / Scala
    jdk
    coursier
    metals
    bloop
    sbt
    scala-cli
    scala-next
    scalafix
    scalafmt
    mill

    # JS
    nodejs
    yarn
    bun

    # Ruby
    ruby
    vips

    # Python
    pkgs.uv

    # nix
    pkgs.nixd
    pkgs.alejandra
    pkgs.deadnix
    pkgs.statix
  ];

  home.file.".zshenv" = {
    source = fileReference ./.zshenv;
  };

  xdg.mime.enable = false;
  xdg.configFile = {
    "git" = {
      source = fileReference ./git;
      recursive = true;
    };
    "ideavim" = {
      source = fileReference ./ideavim;
      recursive = true;
    };
    "zsh" = {
      source = fileReference ./zsh;
      recursive = true;
    };
    "nvim" = {
      source = fileReference ./astronvim;
      recursive = true;
    };
    "tmuxinator" = {
      source = fileReference ./tmuxinator;
      recursive = true;
    };
  };

  # https://github.com/nix-community/home-manager/issues/2995
  programs.man.enable = false;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
