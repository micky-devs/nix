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
    ];
    taps = [
      "supabase/tap"
      "minio/stable"
      "oven-sh/bun"
      "pulumi/tap"
    ];
    brews = [
      "opencode"
      "qemu"
      "posting"
      "supabase/tap/supabase"
      "libpq"
      "minio/stable/mc"
      "oven-sh/bun/bun"
      "doppler"
      "pulumi"
      "pulumi/tap/crd2pulumi"
    ];
  };
  # Add machine-specific system packages, homebrew casks, or settings here if needed
}
