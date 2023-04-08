{ util, lib, ... }:
let
  server_name = "jdonszelmann.nl";
  domain = "matrix.${server_name}";
  port = util.randomPort domain;
  database = util.database {
    name = "matrix";
    type = "postgres";
  };
  reverse-proxy = util.reverse-proxy {
    from = domain;
    to = port;
  };
  server-well-known = util.well-known {
    inherit domain;
    name = "matrix/client";
    config = {
      "m.homeserver".base_url = "https://${domain}";
      "m.identity_server" = { };
    };
  };
  client-well-known = util.well-known {
    inherit domain;
    name = "matrix/server";
    config = {
      "m.server" = "${server_name}:443";
    };
  };
in
lib.mkMerge [
  database.create
  reverse-proxy.create
  server-well-known.create
  client-well-known.create
  {
    services.matrix-synapse = {
      enable = true;
      settings.server_name = server_name;
      settings.listeners = [
        {
          port = port;
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
          database = database.name;
          user = database.username;
        };
      };
    };
  }
]
