{ config, pkgs, lib, secrets, ... }:

{
  imports = [
    ../../common/home.nix
  ];

  programs.awscli.settings = secrets.awsProfiles;
}
