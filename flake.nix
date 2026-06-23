{
  description = "Home Manager configuration of seroperson";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs = {
      url = "github:nixos/nixpkgs/release-25.11";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-claude-code = {
      url = "github:ryoppippi/nix-claude-code";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-claude-code, ... }:
    let
      # linux is the system used for the preview-only outputs (devShell + docker)
      linuxSystem = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${linuxSystem};

      myHomeManagerConfiguration = { system, useSymlinks, homeDirectory, username, dotfilesDirectory }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit useSymlinks homeDirectory username dotfilesDirectory;
            # platform package filters, used inline in home.nix as
            # `onLinux [ ... ]` / `onDarwin [ ... ]` (each yields [] off-platform)
            onLinux = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux;
            onDarwin = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin;
          };

          modules = [
            ./home.nix
            {
              nixpkgs.overlays = [
                nix-claude-code.overlays.default
                (self: super: rec {
                  myJdk = self.jdk21;
                  jdk = myJdk;
                  jre = myJdk;
                  mill = super.mill.override {
                    jre = myJdk;
                  };
                  tmux = nixpkgs-unstable.legacyPackages.${system}.tmux;
                  unstable = import nixpkgs-unstable {
                    inherit (self.stdenv.hostPlatform) system;
                    inherit (self) config;
                  };
                })
              ];
            }
          ];
        };
    in
    {
      devShells.${linuxSystem}.default = pkgs.mkShell rec {
        homeDirectory = builtins.getEnv "HOME";
        username = builtins.getEnv "USER";

        activationPackage = (myHomeManagerConfiguration {
          inherit homeDirectory username;
          system = linuxSystem;
          useSymlinks = false;
          dotfilesDirectory = "";
        }).activationPackage;

        buildInputs = [
          activationPackage
          pkgs.nix
        ];

        shellHook = ''
          export HOME=${homeDirectory}
          export USER=${username}
          # Fixes `Could not find suitable profile directory` error
          mkdir -p ${homeDirectory}/.local/state/nix/profiles
          ${activationPackage}/activate
          # Run zsh and then exit
          IS_PREVIEW=1 exec $HOME/.nix-profile/bin/zsh
        '';
      };

      packages.${linuxSystem}.docker = (import ./nix/docker.nix {
        pkgs = pkgs;
        name = "seroperson.me/dotfiles";
        tag = "latest";
        extraPkgs = with pkgs; [
          ps
          gnused
          coreutils
        ];

        extraContents = [
          (myHomeManagerConfiguration {
            system = linuxSystem;
            useSymlinks = false;
            homeDirectory = "/root";
            username = "root";
            dotfilesDirectory = "";
          }).activationPackage
        ];
        extraEnv = [ "IS_PREVIEW=1" ];
        rootShell = "/root/.nix-profile/bin/zsh";
        cmd = [ "/bin/sh" "-c" "/activate && exec /root/.nix-profile/bin/zsh" ];
        nixConf = {
          allowed-users = [ "*" ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          max-jobs = [ "auto" ];
          sandbox = "false";
          trusted-users = [
            "root"
          ];
        };
      });

      homeConfigurations = {
        "seroperson" = myHomeManagerConfiguration {
          system = linuxSystem;
          useSymlinks = true;
          homeDirectory = "/home/seroperson/";
          username = "seroperson";
          dotfilesDirectory = "/home/seroperson/.dotfiles";
        };
        "seroperson@darwin" = myHomeManagerConfiguration {
          system = "aarch64-darwin";
          useSymlinks = true;
          homeDirectory = "/Users/daniil.sivak";
          # login name is daniil.sivak.2 though $HOME is /Users/daniil.sivak;
          # home-manager asserts $USER == username
          username = "daniil.sivak.2";
          dotfilesDirectory = "/Users/daniil.sivak/.dotfiles";
        };
      };
    };
}
