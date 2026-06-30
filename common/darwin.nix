{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 6;
  system.primaryUser = "micky";

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
    casks = [
      "ghostty"
      "google-chrome"
      "jumpcut"
    ];
    brews = [
      "tree-sitter-cli"
      "just"
      "direnv"
      "colima"
      "redis"
      "atmos"
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
      "zstd"
      "yq"
      "gh"
      "ansible"
      "nmap"
      "mosh"
      "pwgen"
      "ruby"
      "sshpass"
      "wget"
      "uv"
      "gnupg"
      "lima"
      "socket_vmnet"
      "iperf3"
      "lazygit"
      "k9s"
    ];
    onActivation = {
      cleanup = "zap";
      extraFlags = [ "--force" ];
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
