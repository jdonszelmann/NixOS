let
  # host-data = import ../vms/host-data.nix;
  # host-data = config.custom.networking.host;

  proxy-port = domain: port: {
    inherit domain;
    inherit port;
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
  # proxy-vm = domain: hostname: rec {
  #   inherit domain;
  #   port = 8000;
  #   nginx = {
  #     ${domain} = {
  #       enableACME = true;
  #       forceSSL = true;
  #       locations = {
  #         "/" = {
  #           proxyPass = "http://${host-data.host.${hostname}.ip}:${toString port}";
  #           proxyWebsockets = true;
  #         };
  #       };
  #     };
  #   };
  # };
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
  # recipes = proxy-vm "recipes.donsz.nl" "recipes";
  # ifsc-proxy = proxy-vm "ifsc-proxy.donsz.nl" "ifsc-proxy";

  minio = proxy-port "s3.donsz.nl" 11002;
  minio-control = proxy-port "s3c.donsz.nl" 11003;
}
