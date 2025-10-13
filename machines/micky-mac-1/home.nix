{ config, pkgs, lib, ... }:

{
  imports = [
    ../../common/home.nix
  ];

  # Machine-specific home configuration for micky-mac-1
  programs.zsh = {
    shellAliases = {
      rebuild = "sudo nix run nix-darwin -- switch --flake ~/.config/nix#micky-mac-1";
    };
  };
}
