{ config, pkgs, lib, secrets, ... }:

{
  programs.home-manager.enable = true;
  home.username = secrets.username;
  home.homeDirectory = "/Users/${secrets.username}";
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
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/github";
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
      user = secrets.gitUser;
      init = {
        defaultBranch = "main";
      };
      push = {
        autoSetupRemote = true;
      };
      core = { pager = "cat"; };
    };
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      theme = "tokyonight";
      autoshare = false;
      autoupdate = true;
      permission = {
        edit = "ask";
        bash = "ask";
        webfetch = "allow";
      };
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
    };

    initContent = ''
      # Homebrew: put brew + all brew-installed tools on PATH (must come first)
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # Path
      export PATH=$PATH:$HOME/.local/bin

      eval "$(zoxide init zsh)"
      eval "$(direnv hook zsh)"

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
