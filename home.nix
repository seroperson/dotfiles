{ config
, pkgs
, useSymlinks
, homeDirectory
, username
, dotfilesDirectory
, onLinux
, onDarwin
, ...
}:
let
  inherit (import ./nix/utils.nix { inherit config useSymlinks dotfilesDirectory; sourceDirectory = ./.; })
    fileReference;

  # gpg-agent has no reliable PATH when launched on demand, so point it at the
  # pinentry store path directly (GUI prompt on darwin, terminal one on Linux)
  pinentryProgram =
    if pkgs.stdenv.isDarwin
    then "${pkgs.unstable.pinentry_mac}/bin/pinentry-mac"
    else "${pkgs.unstable.pinentry-all}/bin/pinentry";
in
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "yandex-cloud"
      "claude-code"
      "claude"
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
  home.packages = (with pkgs.unstable; [
    # Shell and tools
    git
    zsh
    tmux
    tmuxinator
    ripgrep # Searching file content
    nix-index
    jq # Json manipulation
    yq # Yaml manipulation
    fd # Enhanced find
    bat # Enhanced cat
    eza # Enhanced ls
    ouch # Universal archiver
    comma # Runs programs without installing them
    delta # Enhanced git-diff
    jujutsu # Git-compatible DVCS that is both simple and powerful
    dua # Disk usage
    htop # Enhanced top
    just # Enhanced make
    socat # For proxying SSH
    moor # Rust pager
    nix-search-cli # Use search.nixos.org directly from CLI
    grpcurl # curl for grpc
    pkgs.claude-code
    opencode # AI coding agent for the terminal
    gh # GitHub client
    gnupg # GPG (pinentry installed per-platform below)
    gitlab-runner # GitLab CI runner (registered locally, runs via launchd)
    gdu # Disk Usage
    radare2
    rtk # Improved CLI tools for LLMs

    # using unwrapped nvim allows you to easily use it outside of NixOS
    neovim-unwrapped

    # nvim dependencies
    pkgs.curl
    pkgs.unzip
    pkgs.gzip
    pkgs.gcc
    pkgs.gnutar
    pkgs.gnumake
    pkgs.tree-sitter

    # pekingese control
    kubectl
    kubevpn
    fluxcd
    sops
    postgresql_16
    # yandex-cloud

    # Java / Scala
    pkgs.jdk
    pkgs.coursier
    metals
    pkgs.bloop
    sbt
    pkgs.scala-cli
    pkgs.scalafix
    pkgs.scalafmt
    mill
    gradle_9
    maven
    jdt-language-server

    # JS
    nodejs
    yarn
    bun
    fnm # like nvm, but better
    pnpm

    # Go
    go
    golangci-lint
    gofumpt
    go-task

    # Rust
    rustup

    # Ruby
    rbenv
    rubocop
    libyaml

    # Python
    pkgs.uv
    python313
    # (pkgs.callPackage (import ./nix/python.nix) { })

    # nix
    pkgs.nixd
    pkgs.alejandra
    pkgs.deadnix
    pkgs.statix
  ]) ++ onLinux (with pkgs.unstable; [
    # busybox has no darwin platform support; wsl-open is WSL-only
    busybox
    wsl-open
    awscli2
    # Linux-only: helm 4.2.0's darwin build is broken and uncached
    kubernetes-helm
    pinentry-all
  ]) ++ onDarwin (with pkgs.unstable; [
    pinentry_mac
  ]);

  # LD_LIBRARY_PATH is a no-op on macOS (the dyld loader ignores it), so these
  # native-linking hints only make sense on Linux
  home.sessionVariables = pkgs.lib.optionalAttrs pkgs.stdenv.isLinux (with pkgs; {
    LD_LIBRARY_PATH = lib.concatStringsSep ":" [
      (lib.makeLibraryPath [
        libclang
        glib
        libyaml.out
      ])
      "$HOME/.nix-profile/lib"
      "$LD_LIBRARY_PATH"
    ];
    CPATH = lib.makeSearchPath "include" [ libyaml.dev ];
    LIBRARY_PATH = lib.makeLibraryPath [ libyaml.out ];
  });

  home.file.".zshenv" = {
    source = fileReference ./.zshenv;
  };

  xdg.mime.enable = false;
  xdg.configFile = {
    # GNUPGHOME is set to ~/.config/gnupg in .zshenv, so gpg reads its config
    # (and keeps keys/sockets) here instead of ~/.gnupg. Generated rather than
    # symlinked from a file so the pinentry store path can be interpolated.
    "gnupg/gpg-agent.conf".text = ''
      # Remember an entered passphrase for 7 days (604800s). default = idle TTL,
      # max = hard cap; the *-ssh pair covers the agent's ssh-key cache.
      default-cache-ttl 604800
      max-cache-ttl 604800
      default-cache-ttl-ssh 604800
      max-cache-ttl-ssh 604800
      pinentry-program ${pinentryProgram}
    '';
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
    "gh/config.yml" = {
      source = fileReference ./gh/config.yml;
    };
  };

  nix = {
    enable = true;
    package = pkgs.nix;
    settings = {
      connect-timeout = 5;
      download-attempts = 3;
      fallback = true;
    };
    # machine-local file holding `access-tokens = github.com=...` so
    # flake fetches authenticate (5000/hr vs 60/hr unauthenticated)
    # populated by the `nix-refresh-token` zsh helper; the activation
    # script below ensures it always exists so `!include` never errors
    extraOptions = ''
      !include ${pkgs.lib.removeSuffix "/" homeDirectory}/.config/nix/extra.conf
    '';
  };

  home.activation.ensureNixExtraConf = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${pkgs.lib.removeSuffix "/" homeDirectory}/.config/nix
    run touch ${pkgs.lib.removeSuffix "/" homeDirectory}/.config/nix/extra.conf
  '';

  # GitLab CI runner as a darwin launchd agent. Registered out-of-band via
  # `gitlab-runner register` (writes the auth token to config.toml, untracked);
  # this just keeps it running.
  launchd.agents = pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin (
    let
      home = pkgs.lib.removeSuffix "/" homeDirectory;
    in
    {
      gitlab-runner = {
        enable = true;
        config = {
          ProgramArguments = [
            "${pkgs.unstable.gitlab-runner}/bin/gitlab-runner"
            "run"
            "--working-directory"
            "${home}/.gitlab-runner"
            "--config"
            "${home}/.gitlab-runner/config.toml"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          EnvironmentVariables = {
            # Docker Desktop's socket, not the default /var/run/docker.sock
            DOCKER_HOST = "unix://${home}/.docker/run/docker.sock";
            PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          };
          StandardOutPath = "${home}/.gitlab-runner/runner.log";
          StandardErrorPath = "${home}/.gitlab-runner/runner.log";
        };
      };
    }
  );

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
