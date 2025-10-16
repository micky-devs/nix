{ pkgs, ... }: {
  # Machine-specific darwin configuration for micky-mac-air
  # This file imports common configuration and adds machine-specific settings

  imports = [
    ../../common/darwin.nix
  ];

  homebrew = {
    casks = [
      "claude"
    ];
  };
  # Add machine-specific system packages, homebrew casks, or settings here if needed
}
