{
  config,
  pkgs,
  ...
}:
let
  username = "seroperson";
  homeDirectory = "/home/${username}";
  dotfilesPath = "${homeDirectory}/.dotfiles";
in
{
  imports = [
    ./nix/tmux.nix
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "24.05";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.git

    # using unwrapped nvim allows you to easily use it outside of NixOS
    pkgs.neovim-unwrapped

    # Shell and tools
    pkgs.zsh
    pkgs.ripgrep
    pkgs.fd
    pkgs.bat
    pkgs.jq
    pkgs.eza
    pkgs.tree
    pkgs.tmux
    pkgs.kubectl
    pkgs.unzip
    pkgs.ouch # universal archiver

    # Java / Scala
    pkgs.jre
    pkgs.coursier
    pkgs.metals
    pkgs.bloop
    pkgs.sbt
    pkgs.scala-cli
    pkgs.mill

    # JS
    pkgs.nodejs
    pkgs.yarn

    # Ruby
    pkgs.ruby
    pkgs.vips

    # nix
    pkgs.nixd
    pkgs.alejandra
    pkgs.deadnix
    pkgs.statix

    # Lua
    pkgs.selene
    pkgs.stylua
  ];

  home.file.".zshenv" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/zsh/.zshenv";
  };

  xdg.configFile = {
    "git" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/git";
      recursive = true;
    };
    "ideavim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/ideavim";
      recursive = true;
    };
    "zsh" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/zsh";
      recursive = true;
    };
    "nix" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/nix";
      recursive = true;
    };

    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/astronvim";
      recursive = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
