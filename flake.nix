{
  description = "One flake to rule them all";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    discordOverlay = (final: prev: {
      discord = prev.discord.overrideAttrs (old: rec {
        version = "0.0.104";
        src = prev.fetchurl {
          url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
          sha256 = "19rx408b5zwdishli5pdgd2as0nb91nr3shwa0j3hdfih7sh43z3";
        };
      });
    });
  in
  {
    nixosConfigurations = {
      tungsten = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          # Make the overlay and unfree active for the system build
          ({ ... }: {
            nixpkgs = {
              overlays = [ discordOverlay ];
              config.allowUnfree = true;
            };
          })
        ];
      };
    };

    homeConfigurations = {
      david = home-manager.lib.homeManagerConfiguration {
        # keep your existing pkgs line if you want,
        # but ensure HM sees the overlay too:
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          ./home.nix
          ({ ... }: {
            nixpkgs = {
              overlays = [ discordOverlay ];
              config.allowUnfree = true;
            };
          })
        ];
      };
    };
  };
}

