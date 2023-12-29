let
  host-data = import ../vms/host-data.nix;
  proxy-port = domain: port: {
    inherit domain;
    port = port;
    nginx = {
      ${domain} = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString port}";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
  proxy-vm = domain: hostname: port: {
    inherit domain;
    port = port;
    nginx = {
      ${domain} = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://${host-data.${hostname}.ip}:${toString port}";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
in
{
  matrix = rec {
    server_name = "jdonszelmann.nl";
    domain = "matrix.${server_name}";
    port = 11001;
    nginx = {
      ${domain} =
        {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://[::1]:${toString port}";
          locations."/_matrix".proxyPass = "http://[::1]:${toString port}";
          locations."/_synapse/client".proxyPass = "http://[::1]:${toString port}";
        };
      ${server_name} = {
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
  recipes = proxy-port "recipes.donsz.nl" 11002;

  ifsc-proxy = proxy-vm "ifsc-proxy.donsz.nl" "ifsc-proxy" 8000;
}

