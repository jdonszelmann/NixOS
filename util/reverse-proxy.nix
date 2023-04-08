{ nixpkgs, ... }: with builtins; with { lib = (nixpkgs.lib); };
{
  well-known = { domain, name, config, ... }@args: {
    create = {
      services.nginx = {
        virtualHosts.${domain} = {
          # put all the locations in the config
          locations = {
            "/.well-known/${name}".extraConfig = ''
              add_header Content-Type application/json;
              add_header Access-Control-Allow-Origin *;
              return 200 '${builtins.toJSON config}';
            '';
          };
        };
      };
    };
  };
  reverse-proxy = { from, to }@args:
    assert (isString from);
    assert (isInt to);
    {
      create = {
        services.nginx = {
          virtualHosts.${from} = {
            listen = lib.mkIf (args?onPort) {
              port = args.onPort;
              address = "0.0.0.0";
            };

            enableACME = true;
            forceSSL = true;

            # put all the locations in the config
            locations = {
              "/" = {
                proxyPass = "http://localhost:${toString to}";
                proxyWebsockets = true;
              };
            };
          };
        };
      };
    };
}
