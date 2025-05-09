{
  config,
  pkgs,
  vars,
  ...
}:
let
  baseName = p: with builtins;
    let
      bp = baseNameOf ( toString p );
      isBaseName = mb: ( baseNameOf mb ) == mb;
      isNixStorePath = nsp:
        let prefix = "/nix/store/"; plen = stringLength prefix; in
        prefix == ( substring 0 plen ( toString nsp ) );
      removeNixStorePrefix = nsp:
        let m = match "/nix/store/[^-]+-(.*)" ( toString nsp ); in
        if m == null then nsp else ( head m );
    in baseNameOf ( removeNixStorePrefix ( p ) );

  fileReference = path:
    if vars.useSymlinks
      then config.lib.file.mkOutOfStoreSymlink "${vars.dotfilesDirectory}/${baseName path}"
      else path;

in {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "yandex-cloud"
    ];

  imports = [
    ./nix/tmux.nix
  ];

  home = {
    # Requires --impure flag
    homeDirectory = vars.homeDirectory;
    username = vars.username;
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
    source = fileReference .config/zsh/.zshenv;
  };

  xdg.mime.enable = false;
  xdg.configFile = {
    "git" = {
      source = fileReference .config/git;
      recursive = true;
    };
    "ideavim" = {
      source = fileReference .config/ideavim;
      recursive = true;
    };
    "zsh" = {
      source = fileReference .config/zsh;
      recursive = true;
    };
    "nix" = {
      source = fileReference .config/nix;
      recursive = true;
    };
    "nvim" = {
      source = fileReference .config/astronvim;
      recursive = true;
    };
    "tmuxinator" = {
      source = fileReference .config/tmuxinator;
      recursive = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
