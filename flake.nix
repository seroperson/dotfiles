{
  description = "Home Manager configuration of seroperson";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs = {
      url = "github:nixos/nixpkgs/release-23.11";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      username = "seroperson";
      homeDirectory = "/home/${username}/";
    in {
      devShells.${system}.default = pkgs.mkShell {
        NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";

        packages = [
          pkgs.home-manager
          pkgs.git
        ];
      };

      homeConfigurations."seroperson" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          {
            nixpkgs.overlays = [
              (self: super: {
                jre = super.jdk17;
              })
            ];
          }

          ./home.nix
        ];

        extraSpecialArgs = {
          homeDirectory = homeDirectory;
          username = username;
          dotfilesPath = "${homeDirectory}/.dotfiles/";
        };
      };

      programs.zsh.enable = true;
      environment.shells = with pkgs; [ zsh ];
      users.defaultUserShell = pkgs.zsh;
    };
}
