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
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "yandex-cloud"
    ];

  imports = [
    ./nix/tmux.nix
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "24.11";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.git

    # using unwrapped nvim allows you to easily use it outside of NixOS
    pkgs.neovim-unwrapped

    # Shell and tools
    pkgs.zsh
    pkgs.tmux
    pkgs.tmuxinator
    pkgs.ripgrep # Searching file content
    pkgs.jq # Shell json manipulation
    pkgs.yq # Shell yaml manipulation
    pkgs.fd # Enhanced find
    pkgs.bat # Enhanced cat
    pkgs.eza # Enhanced ls
    pkgs.unzip
    pkgs.ouch # Universal archiver
    pkgs.wsl-open
    pkgs.aider-chat

    # pekingese control
    pkgs.kubectl
    pkgs.fluxcd
    pkgs.kubernetes-helm
    pkgs.sops
    pkgs.postgresql_16
    pkgs.awscli2
    pkgs.yandex-cloud

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

    # Python
    pkgs.uv

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

  # systemd.user.enable = false;

  xdg.mime.enable = false;
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
    "tmuxinator" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/tmuxinator";
      recursive = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
