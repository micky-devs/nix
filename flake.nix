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

  outputs = { self, nixpkgs, darwin, home-manager }: {
    darwinConfigurations = {
      micky-mac-1 = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./machines/micky-mac-1/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.micky = import ./machines/micky-mac-1/home.nix;
          }
        ];
      };

      micky-mac-air = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./machines/micky-mac-air/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.micky = import ./machines/micky-mac-air/home.nix;
          }
        ];
      };
    };
  };
}
