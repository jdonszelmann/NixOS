{ ... }: {
  custom.networking = {
    host.ifsc-proxy = {
      ip = "10.0.0.2";
      mac = "02:00:00:00:00:02";
      proxy."ifsc-proxy.donsz.nl" = { };
    };

    host.recipes = {
      ip = "10.0.0.3";
      mac = "02:00:00:00:00:03";
      proxy."recipes.donsz.nl" = { };
    };

    proxy.matrix = rec {
      custom.server_name = "jdonszelmann.nl";
      domain = "matrix.${custom.server_name}";
      port = 11001;
      to = "[::1]";
      extraNginxConfig = {
        ${domain} =
          {
            locations."/_matrix".proxyPass = "http://[::1]:${toString port}";
            locations."/_synapse/client".proxyPass = "http://[::1]:${toString port}";
          };
        ${custom.server_name} = {
          enableACME = true;
          forceSSL = true;
          locations."/.well-known/matrix/client".extraConfig = ''
                    add_header Content-Type application/json;
                    add_header Access-Control-Allow-Origin *;
                    return 200 '${builtins.toJSON {
              "m.homeserver".base_url = "https://${domain}";
              "m.identity_server" = { };
            }}';
          '';
          locations."/.well-known/matrix/server".extraConfig = ''
                  add_header Content-Type application/json;
                  add_header Access-Control-Allow-Origin *;
                  return 200 '${builtins.toJSON {
              "m.server" = "${domain}:443";
            }}';
          '';
        };
      };
    };

    proxy."s3.donsz.nl" = { port = 11002; };
    proxy."s3c.donsz.nl" = { port = 11003; };
  };
}
