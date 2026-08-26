{ pkgs, secrets, ... }: {
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 6;
  system.primaryUser = secrets.username;

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
      "handy"
    ];
    brews = [
      "opencode"
      "qemu"
      "posting"
      "libpq"
      "oven-sh/bun/bun"
      "pulumi"
      "pulumi/tap/crd2pulumi"
      "tree-sitter-cli"
      "just"
      "direnv"
      "colima"
      "nvm"
      "asitop"
      "go"
      "neovim"
      "fzf"
      "tmux"
      "rg"
      "helm"
      "docker"
      "docker-buildx"
      "docker-compose"
      "zstd"
      "yq"
      "ansible"
      "nmap"
      "pwgen"
      "sshpass"
      "wget"
      "uv"
      "gnupg"
      "lima"
      "socket_vmnet"
      "iperf3"
      "fio"
      "lazygit"
      "k9s"
    ];
    onActivation = {
      cleanup = "zap";
      extraFlags = [ "--force" ];
    };
  };

  users.users.${secrets.username} = {
    name = secrets.username;
    home = "/Users/${secrets.username}";
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    build-users-group = "nixbld";
  };
}
