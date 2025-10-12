{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = "micky"; 
  home.homeDirectory = "/Users/micky";
  home.stateVersion = "25.05";
  
  home.packages = with pkgs; [
    git
    zoxide
    zsh
    go-task
    awscli2
    neovim
    tenv
    tree
    google-chrome
    plex
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true; 
    userName = "MichaelReubenDev";
    userEmail = "michael.reuben.mellor@gmail.com";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      tfp = "terraform plan";
    };
    
    initExtra = ''
      eval "$(zoxide init zsh)"
    '';

    sessionVariables = {
      EDITOR = "nvim";
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["docker" "aws" "git"];
      theme = "kolo";
    };
  };
}
