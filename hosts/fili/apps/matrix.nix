{ util, lib, config, ... }:
let
  vs = config.vault-secrets.secrets;
  server_name = "jdonszelmann.nl";
  domain = "matrix.${server_name}";
  register-domain = "matrix-register.jdonszelmann.nl";
  register-port = util.randomPort register-domain;

  # todo: use random port
  port = 8008;
  database = util.database {
    name = "matrix";
    type = "postgres";
  };
  reverse-proxy = util.reverse-proxy {
    from = domain;
    to = port;
  };
  client-well-known = util.well-known {
    domain = server_name;
    name = "matrix/client";
    config = {
      "m.homeserver".base_url = "https://${domain}";
      "m.identity_server" = { };
    };
  };
  server-well-known = util.well-known {
    domain = server_name;
    name = "matrix/server";
    config = {
      "m.server" = "${domain}:443";
    };
  };

  register-reverse-proxy = util.reverse-proxy {
    from = register-domain;
    to = register-port;
  };
in
lib.mkMerge [
  database.create
  # reverse-proxy.create
  register-reverse-proxy.create
  server-well-known.create
  client-well-known.create
  {
    vault-secrets.secrets.matrix = { };

    services.nginx = {
      virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        # locations."/".extraConfig = '' 
        # return 404;
        # '';
        locations."/".proxyPass = "http://[::1]:${toString port}";
        locations."/_matrix".proxyPass = "http://[::1]:${toString port}";
        locations."/_synapse/client".proxyPass = "http://[::1]:${toString port}";
      };
    };

    services.matrix-synapse = {
      enable = true;
      settings.server_name = server_name;
      environmentFile = "${vs.matrix}/environment";
      registration_shared_secret = "$REGISTRATION_SHARED_SECRET";
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

    services.matrix-registration = {
      enable = true;
      settings = {
        port = register-port;
        host = "0.0.0.0";
      };
    };
  }
]
