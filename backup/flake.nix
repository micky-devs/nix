{
  description = "Micky Mac";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "aarch64-darwin"; 
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    homeConfigurations.micky = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
     
      modules = [
        ./home.nix
      ];
    };
  };
}
