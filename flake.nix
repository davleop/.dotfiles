{
  description = "One flake to rule them all";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    claude-code-nix.url = "github:sadjow/claude-code-nix";
  };
  outputs = { self, nixpkgs, home-manager, claude-code-nix, ... }:
  let
    system = "x86_64-linux";
    discordOverlay = final: prev: {
      discord = prev.discord.overrideAttrs (old: rec {
        version = "0.0.104";
        src = prev.fetchurl {
          url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
          sha256 = "19rx408b5zwdishli5pdgd2as0nb91nr3shwa0j3hdfih7sh43z3";
        };
      });
    };
    overlays = [ discordOverlay ];
  in
  {
    nixosConfigurations = {
      tungsten = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ({ ... }: {
            nixpkgs = {
              overlays = overlays;
              config.allowUnfree = true;
            };
          })
        ];
      };
    };
    homeConfigurations = {
      david = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          claude-code-pkg = claude-code-nix.packages.${system}.claude-code;
        };
        modules = [
          ./home.nix
        ];
      };
    };
  };
}
