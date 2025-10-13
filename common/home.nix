{ config, pkgs, lib, ... }:

{
  programs.home-manager.enable = true;
  home.username = "micky";
  home.homeDirectory = "/Users/micky";
  home.stateVersion = "25.05";

  home.activation = {
    generateSSHKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
      bash .config/nix/scripts/generateSSHKey.sh
    '';
    setupNvim = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH=/usr/bin:$PATH
      bash .config/nix/scripts/setupNvim.sh
    '';
  };


  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      font-family = "CaskaydiaCove Nerd Font";
      font-size = "22";
      background = "282c34";
      background-opacity = "0.9";
      background-blur = true;
    };
  };

  programs.awscli = {
    enable = true;
    settings = {
      default = {
        region = "eu-west-2";
        sso_region = "eu-west-1";
        sso_account_id = "575324938096";
        sso_role_name = "AdministratorAccess";
        cli_pager="jq";
        sso_start_url = "https://d-936776dfd6.awsapps.com/start";
      };
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/github";
      };
      MichaelReubenDevSlalom = {
        identityFile = "~/.ssh/MichaelReubenDevSlalom";
        hostname = "github.com";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "MichaelReubenDev";
    userEmail = "michael.reuben.mellor@gmail.com";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      push = {
        autoSetupRemote = true;
      };
      core.pager = "cat";
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      cd = "z";
      tfp = "terraform plan";
      tfa = "terraform apply --auto-approve";
      k = "kubectl";
      rebuild = "sudo nix run nix-darwin -- switch --flake ~/.config/nix";
    };

    initExtra = ''
      # Path
      export PATH=$PATH:/Users/micky/.local/bin

      eval "$(zoxide init zsh)"

      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
    '';

    sessionVariables = {
      EDITOR = "nvim";
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["docker" "aws" "git" "helm" "kubectl"];
      theme = "kolo";
    };
  };
}
