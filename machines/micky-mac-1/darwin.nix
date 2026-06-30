{ pkgs, ... }: {
  # Machine-specific darwin configuration for micky-mac-1
  # This file imports common configuration and adds machine-specific settings

  imports = [
    ../../common/darwin.nix
  ];

  homebrew = {
    casks = [
      "plex"
    ];
  };
}
