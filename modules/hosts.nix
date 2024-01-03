{ lib, config, ... }:
with lib; with builtins; with types;
let
  cfg = config.custom.networking;

  proxy = default-to: submodule ({ name, ... }:
    {
      options = {
        domain = mkOption {
          type = str;
          description = ''
            A domain name you want this machine to have
          '';
          default = name;
        };
        to = mkOption {
          type = str;
          description = ''
            Where to proxy to.
          '';
          default = default-to;
        };
        port = mkOption {
          type = port;
          default = 8000;
          description = ''
            The port this service runs on.
          '';
        };
        extraNginxConfig = mkOption {
          type = attrs;
          default = { };
          description = ''
            Any extra config that nginx should have for this proxy setup.
          '';
        };
        extraNginxDomainConfig = mkOption {
          type = attrs;
          default = { };
          description = ''
            Any extra config that nginx should have for the currently proxied domain.
          '';
        };
        custom = mkOption {
          type = attrs;
          default = { };
          description = ''
            Any custom configuration you want to associate with this proxy.
          '';
        };
      };
    });

  host = submodule ({ name, ... }: {
    options = {
      hostname = mkOption {
        type = str;
        default = name;
        description = ''
          the machine's hostname
        '';
      };
      ip = mkOption {
        type = str;
        description = ''
          the machine's ip address
        '';
      };
      mac = mkOption {
        type = str;
        description = ''
          the machine's mac address
        '';
      };
      proxy = mkOption
        {
          type = attrsOf (proxy cfg.host.${name}.ip);
          description = "different domains that are exposed";
        };
    };
  });
in
{
  options.custom.networking = mkOption ({
    type = submodule
      {
        options = {
          host = mkOption {
            type = attrsOf host;
            description = ''
              The configuration for each of the different hosts.
            '';
          };
          proxy = mkOption {
            type = attrsOf (proxy "127.0.0.1");
            description = ''
              The configuration for each of the different hosts.
            '';
          };
        };
      };
    description = ''
      The networking config of the server. 
      What hosts exists at what IPs, 
      and what the reverse proxy setup looks like.
    '';
  });

  config =
    let
      attrValues = lib.attrsets.attrValues;

      hosts = attrValues config.custom.networking.host;
      proxies = attrValues config.custom.networking.proxy;
      host-proxies = builtins.concatMap (host: attrValues host.proxy) hosts;
      all-proxies = proxies ++ host-proxies;
      virtualHosts = foldl'
        (a: b: mkMerge [ a b ])
        { }
        (
          map
            (proxy: mkMerge [
              {
                ${proxy.domain} = mkMerge [
                  {
                    enableACME = true;
                    forceSSL = true;
                    locations = {
                      "/" = {
                        proxyPass = "http://${proxy.to}:${toString proxy.port}";
                        proxyWebsockets = true;
                      };
                    };
                  }
                  proxy.extraNginxDomainConfig
                ];
              }
              proxy.extraNginxConfig
            ])
            all-proxies
        );
    in
    {
      services.nginx.virtualHosts = virtualHosts;
    };
}

