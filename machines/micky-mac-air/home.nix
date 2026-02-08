{ config, pkgs, lib, ... }:

{
  imports = [
    ../../common/home.nix
  ];

  # Machine-specific home configuration for micky-mac-air
  # Add machine-specific overrides here if needed

  programs.opencode = {
    enable = true;
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

  programs.awscli.settings = {
    "profile training-mgmt" = {
      region = "eu-west-2";
      sso_region = "eu-west-2";
      sso_account_id = "331221168488";
      sso_role_name = "AdministratorAccess";
      cli_pager="jq";
      sso_start_url = "https://d-9c67428584.awsapps.com/start";
    };
    "profile training-prod" = {
      region = "eu-west-2";
      sso_region = "eu-west-2";
      sso_account_id = "854768053469";
      sso_role_name = "AdministratorAccess";
      cli_pager="jq";
      sso_start_url = "https://d-9c67428584.awsapps.com/start";
    };
    "profile training-dev" = {
      region = "eu-west-2";
      sso_region = "eu-west-2";
      sso_account_id = "928530207471";
      sso_role_name = "AdministratorAccess";
      cli_pager="jq";
      sso_start_url = "https://d-9c67428584.awsapps.com/start";
    };
  };
}
