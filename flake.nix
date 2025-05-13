{
  description = "Home Manager configuration of seroperson";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      myHomeManagerConfiguration = useSymlinks: homeDirectory: username: dotfilesDirectory: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit useSymlinks homeDirectory username dotfilesDirectory;
        };

        modules = [
          ./home.nix
          {
            nixpkgs.overlays = [
              (self: super: {
                jre = super.jdk17;
              })
            ];
          }
        ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          (myHomeManagerConfiguration false (builtins.getEnv "HOME") (builtins.getEnv "USER") "").activationPackage
        ];

        shellHook = ''
          # Fixes `Could not find suitable profile directory` error
          mkdir -p $HOME/.local/state/nix/profiles
          $buildInputs/activate
          chsh -s $HOME/.nix-profile/bin/zsh $USER
          # Run zsh and then exit
          IS_PREVIEW=1 exec $HOME/.nix-profile/bin/zsh
        '';
      };

      homeConfigurations = {
        "seroperson" = myHomeManagerConfiguration true "/home/seroperson/" "seroperson" "/home/seroperson/.dotfiles";
      };
    };
}
