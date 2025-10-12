{
  description = "Micky Mac";

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
    darwinConfigurations."micky-mac-1" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
	./darwin-configuration.nix
	home-manager.darwinModules.home-manager
	{
	  home-manager.useGlobalPkgs = true;
	  home-manager.useUserPackages = true; 
	  home-manager.users.micky = import ./home.nix;
	}
      ];
    }; 
  }; 
}
