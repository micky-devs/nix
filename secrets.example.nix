{
  username = "micky";

  gitUser = {
    name = "your-git-username";
    email = "you@example.com";
  };

  mcp = {
    homeassistantUrl = "https://homeassistant.example.com/api/mcp";
    grafanaUrl = "https://grafana.example.com";
  };

  awsProfiles = {
    default = {
      region = "eu-west-2";
      sso_region = "eu-west-1";
      sso_account_id = "000000000000";
      sso_role_name = "AdministratorAccess";
      cli_pager = "jq";
      sso_start_url = "https://d-0000000000.awsapps.com/start";
    };
  };
}
