{ config, pkgs, lib, ... }:

{
  programs.home-manager.enable = true;
  home.username = "micky";
  home.homeDirectory = "/Users/micky";
  home.stateVersion = "25.11";

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
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/github";
      };
      micky-mac-1 = {
        identityFile = "~/.ssh/micky-mac-1";
      };
      "gitlab.com" = {
        identityFile = "~/.ssh/gitlab";
      };
      lima-default = {
        extraOptions = {
          UserKnownHostsFile = "/dev/null";
          StrictHostKeyChecking = "no";
        };
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "micky-devs";
        email = "miester2001@hotmail.co.uk";
      };
      init = {
        defaultBranch = "main";
      };
      push = {
        autoSetupRemote = true;
      };
      core = { pager = "cat"; };
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      cd = "z";
      tfp = "terraform plan";
      tfa = "terraform apply --auto-approve";
      k = "kubectl";
      rebuild = "sudo -H nix run nix-darwin -- switch --flake ~/.config/nix";
      ahh = "echo ahhhh! cunt!";
    };

    initContent = ''
      # Path
      export PATH=$PATH:/Users/micky/.local/bin

      eval "$(zoxide init zsh)"

      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"

      export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
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
