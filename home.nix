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
      "claude-code"
    ];

  imports = [
    ./nix/tmux.nix
  ];

  home = {
    inherit homeDirectory username;
    stateVersion = "25.11";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs.unstable; [
    # Shell and tools
    git
    zsh
    busybox
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
    comma # Runs programs without installing them
    nix-index
    delta # Enhanced git-diff
    concurrently
    jujutsu # Git-compatible DVCS that is both simple and powerful
    dua # Disk usage
    htop # Enhanced top
    just # Enhanced make
    socat # For proxying SSH
    moor # Rust pager
    nix-search-cli # Use search.nixos.org directly from CLI
    grpcurl # curl for grpc
    claude-code # it actually happened.

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
    pkgs.ruby

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
    pkgs.jdk
    pkgs.coursier
    metals
    pkgs.bloop
    (pkgs.callPackage (import ./nix/sbt.nix) { })
    pkgs.scala-cli
    pkgs.scalafix
    pkgs.scalafmt
    mill
    gradle_9

    # JS
    nodejs
    yarn
    bun
    fnm # like nvm, but better

    # Python
    pkgs.uv
    python313
    # (pkgs.callPackage (import ./nix/python.nix) { })

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
    "jj" = {
      source = fileReference ./jj;
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
