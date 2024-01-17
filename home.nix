{
  callPackage,
  config,
  pkgs,
  username,
  homeDirectory,
  dotfilesPath,
  lib,
  ...
}:

{

  imports = [
    ./nix/tmux.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.git

    pkgs.neovim

    pkgs.zsh

    pkgs.ripgrep
    pkgs.bat
    pkgs.jq
    pkgs.eza
    pkgs.tree
    pkgs.tmux
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
      source = pkgs.fetchFromGitHub {
        owner = "AstroNvim";
        repo = "AstroNvim";
        rev  = "271c9c3f71c2e315cb16c31276dec81ddca6a5a6";
        sha256 = "h019vKDgaOk0VL+bnAPOUoAL8VAkhY6MGDbqEy+uAKg=";
      };
    };
    # AstronVim allows you to separate custom configuration from repository itself
    # docs.astronvim.com/configuration/manage_user_config/#setting-up-a-user-configuration
    "astronvim/lua/user" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/astronvim";
      recursive = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
