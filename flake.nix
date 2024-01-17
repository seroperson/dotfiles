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
  };

  outputs = { nixpkgs, home-manager, ... }:
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
            # Fixing treesitter
            # https://github.com/NixOS/nixpkgs/issues/207003
            # https://github.com/NixOS/nixpkgs/issues/130152
            # https://github.com/NixOS/nixpkgs/pull/261103
            nixpkgs.overlays = [
              (self: super: {
                neovim = super.neovim.overrideAttrs (o: {
                  installPhase = ''
                    wrapProgram $out/bin/nvim \
                      --set LD_LIBRARY_PATH ${pkgs.stdenv.cc.cc.lib}/lib
                  '';
                });
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
