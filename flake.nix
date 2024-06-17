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

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";

        packages = [
          pkgs.home-manager
          pkgs.git
        ];
      };

      homeConfigurations = {
        "seroperson" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

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

      programs.zsh.enable = true;
      environment.shells = with pkgs; [ zsh ];
      users.defaultUserShell = pkgs.zsh;
    };
  };
}
