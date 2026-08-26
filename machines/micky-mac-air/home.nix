{ config, pkgs, lib, secrets, ... }:

{
  imports = [
    ../../common/home.nix
  ];

  programs.opencode.settings.mcp = {
    homeassistant = {
      type = "remote";
      url = secrets.mcp.homeassistantUrl;
      enabled = true;
      headers = {
        Authorization = "Bearer {env:HOMEASSISTANT_MCP_TOKEN}";
      };
    };
    metabase-server = {
      type = "local";
      command = [ "metabase-server" ];
    };
    grafana = {
      type = "local";
      command = [ "uvx" "mcp-grafana" ];
      environment = {
        GRAFANA_URL = secrets.mcp.grafanaUrl;
        GRAFANA_SERVICE_ACCOUNT_TOKEN = "{env:GITLAB_MCP_TOKEN}";
      };
    };
  };

  programs.awscli.settings = secrets.awsProfiles;
}
