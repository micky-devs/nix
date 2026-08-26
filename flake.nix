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
      loadSecrets = hostname:
        let machineSecrets = ./machines/${hostname}/secrets.nix;
        in if builtins.pathExists machineSecrets
        then import machineSecrets
        else import ./secrets.example.nix;

      mkDarwinConfig = hostname:
        let secrets = loadSecrets hostname;
        in darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit secrets hostname; };
          modules = [
            ./machines/${hostname}/darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit secrets hostname; };
              home-manager.users.${secrets.username} = import ./machines/${hostname}/home.nix;
            }
          ];
        };

      machines = [
        "micky-mac-1"
        "micky-mac-air"
        "micky-mac-slalom"
      ];

      # Real hostname -> friendly directory name under ./machines.
      hostAliases = {
        "m73292224" = "micky-mac-slalom";
      };
    in
    {
      darwinConfigurations =
        nixpkgs.lib.genAttrs machines mkDarwinConfig
        // nixpkgs.lib.mapAttrs (_: mkDarwinConfig) hostAliases;
    };
}
