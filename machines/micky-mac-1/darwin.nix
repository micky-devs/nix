{ pkgs, ... }: {
  # Machine-specific darwin configuration for micky-mac-1
  # This file imports common configuration and adds machine-specific settings

  imports = [
    ../../common/darwin.nix
  ];

  # Add machine-specific system packages, homebrew casks, or settings here if needed
}
