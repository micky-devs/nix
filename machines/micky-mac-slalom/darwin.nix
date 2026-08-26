{ pkgs, ... }: {
  imports = [
    ../../common/darwin.nix
  ];

  homebrew = {
    casks = [
      "slack"
      "obsidian"
      "spotify"
    ];
  };
}
