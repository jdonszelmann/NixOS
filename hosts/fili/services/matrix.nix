{ config, pkgs, ... }:
let
  server_name = config.custom.networking.proxy.matrix.custom.server_name;
  port = config.custom.networking.proxy.matrix.port;
in
{
  services.matrix-synapse = {
    enable = true;
    settings = {
      inherit server_name;
      url_preview_enabled = true;
    };
    settings.listeners = [
      {
        inherit port;
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
