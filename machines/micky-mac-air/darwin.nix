{ pkgs, ... }: {
  # Machine-specific darwin configuration for micky-mac-air
  # This file imports common configuration and adds machine-specific settings

  imports = [
    ../../common/darwin.nix
  ];

  homebrew = {
    casks = [
      "slack"
      "vlc"
      "genymotion"
      "balenaetcher"
      "raspberry-pi-imager"
      "thunderbird"
      "obsidian"
      "whatsapp"
      "spotify"
      "tor-browser"
      "mullvad-vpn"
    ];
    taps = [
      "oven-sh/bun"
      "pulumi/tap"
    ];
  };
}
