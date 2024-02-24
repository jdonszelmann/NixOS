{ config, ... }: {
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

    host.torrent = {
      ip = "10.0.0.4";
      mac = "02:00:00:00:00:04";
      proxy."torrent.donsz.nl" = { };
    };

    host.factorio = {
      ip = "10.0.0.5";
      mac = "02:00:00:00:00:05";
      proxy."factorio.donsz.nl" = { };
    };

    # TODO: run jellyfin in a vm with graphics passthrough.
    # host.jellyfin = {
    # ip = "10.0.0.4";
    # mac = "02:00:00:00:00:04";
    proxy."media.donsz.nl" = {
      port = 8096;
      extraNginxDomainConfig = {
        locations."/".extraConfig = ''
          proxy_buffering off;
        '';
        locations."/socket" = {
          inherit (config.services.nginx.virtualHosts."media.donsz.nl".locations."/") proxyPass;
          proxyWebsockets = true;
        };
      };
    };
    # };

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

    proxy."relay-status.donsz.nl" = { port = 11004; };

    # aliases
    proxy."req.donsz.nl" = { port = 5555; };
    proxy."overseerr.donsz.nl" = { port = 5555; };
    proxy."sonarr.donsz.nl" = { port = 8989; };
    proxy."radarr.donsz.nl" = { port = 7878; };

  };
}
