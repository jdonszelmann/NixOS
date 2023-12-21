{ config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
  proxies = import ./reverse-proxy-data.nix;
in
{
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = proxies.matrix.server_name;
      url_preview_enabled = true;
    };
    settings.listeners = [
      {
        port = proxies.matrix.port;
        bind_addresses = [ "::1" ];
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [ "client" "federation" ];
          compress = true;
        }];
      }
    ];

    settings.database = {
      name = "psycopg2";
      args = {
        database = "matrix";
        user = "matrix";
      };
    };
  };
}
