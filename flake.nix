{
  description = "Home Manager configuration of seroperson";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs = {
      url = "github:nixos/nixpkgs/release-24.05";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      myHomeManagerConfiguration = { useSymlinks, homeDirectory, username, dotfilesDirectory }@extraSpecialArgs:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs extraSpecialArgs;

          modules = [
            ./home.nix
            {
              nixpkgs.overlays = [
                (self: super: rec {
                  myJdk = self.jdk21;
                  jdk = myJdk;
                  jre = myJdk;
                  sbt = super.sbt.override {
                    jre = myJdk;
                  };
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
      devShells.${system}.default = pkgs.mkShell rec {
        homeDirectory = builtins.getEnv "HOME";
        username = builtins.getEnv "USER";

        activationPackage = (myHomeManagerConfiguration {
          inherit homeDirectory username;
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

      packages.${system}.docker = (import ./nix/docker.nix {
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
          useSymlinks = true;
          homeDirectory = "/home/seroperson/";
          username = "seroperson";
          dotfilesDirectory = "/home/seroperson/.dotfiles";
        };
      };
    };
}
