{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 6;

  # Disable natural scrolling
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  # Nix Packages
  environment.systemPackages = with pkgs; [
    git
    zoxide
    zsh
    go-task
    awscli2
    tenv
    tree
    nerd-fonts.caskaydia-mono
    ollama
  ];

  fonts = {
    packages = with pkgs; [
     nerd-fonts.caskaydia-mono
    ];
  };

  # Homebrew
  homebrew = {
    enable = true;
    taps = [
      "fluxcd/tap"
    ];
    casks = [
      "ghostty"
      "google-chrome"
      "plex"
      "jumpcut"
      "raspberry-pi-imager"
      "bitwarden"
      "thunderbird"
      "obsidian"
      "whatsapp"
      "spotify"
      "orbstack"
      "tor-browser"
      "mullvad-vpn"
    ];
    brews = [
      "nvm"
      "asitop"
      "go"
      "pipx"
      "neovim"
      "fzf"
      "tmux"
      "rg"
      "minikube"
      "helm"
      "docker"
      "docker-buildx"
      "docker-compose"
      "fluxcd/tap/flux"
      "zstd"
      "gomplate"
      "yq"
      "argocd"
      "gh"
      "ansible"
      "nmap"
      "mosh"
      "pwgen"
      "ruby"
      "sshpass"
      "glab"
      "wget"
      "uv"
      "gnupg"
      "lima"
    ];
    onActivation = {
      cleanup = "zap";
    };
  };

  users.users.micky = {
    name = "micky";
    home = "/Users/micky";
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    build-users-group = "nixbld";
  };
}
