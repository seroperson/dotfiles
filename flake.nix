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

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      myHomeManagerConfiguration = useSymlinks: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs;
          vars = rec {
            inherit useSymlinks;
            homeDirectory = builtins.getEnv "HOME";
            username = builtins.getEnv "USER";
            dotfilesDirectory = "${homeDirectory}/.dotfiles/";
          };
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
        NIX_CONFIG = "extra-experimental-features = nix-command flakes";

        packages = [
          pkgs.home-manager
          (myHomeManagerConfiguration false).activationPackage
        ];

        pwdPath = builtins.toString ./.;

        shellHook = ''
          export USER=seroperson-preview
          export HOME=$(mktemp -d)
          mkdir -p $HOME/.local/state/nix/profiles
          home-manager --impure init --switch $pwdPath --flake $pwdPath#homeConfigurations.seroperson-preview.activationPackage
          chsh -s $HOME/.nix-profile/bin/zsh
          $HOME/.nix-profile/bin/zsh
          trap "rm -rf $HOME" EXIT
        '';
      };

      homeConfigurations = {
        "seroperson" = myHomeManagerConfiguration true;
        "seroperson-preview" = myHomeManagerConfiguration false;
      };
    };
}
