{
  description = "Micky's Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager }:
    let
      # Helper function to create a darwin configuration for a given hostname
      mkDarwinConfig = hostname: darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./machines/${hostname}/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.micky = import ./machines/${hostname}/home.nix;
          }
        ];
      };

      # List of all your machines
      machines = [ "micky-mac-1" "micky-mac-air" ];
    in
    {
      # Generate configurations for all machines
      darwinConfigurations = nixpkgs.lib.genAttrs machines mkDarwinConfig;
    };
}
