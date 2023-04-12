{ util, lib, config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
  domain = "s3.donsz.nl";
  console-domain = "s3c.donsz.nl";
  port = util.randomPort domain;
  console-port = util.randomPort console-domain;
  reverse-proxy = util.reverse-proxy {
    from = domain;
    to = port;
  };
  console-reverse-proxy = util.reverse-proxy {
    from = console-domain;
    to = console-port;
  };
in
lib.mkMerge [
  reverse-proxy.create
  console-reverse-proxy.create
  {
    vault-secrets.secrets.garage = { };

    services.garage = {
      enable = true;
      package = pkgs.garage;
      #   rootCredentialsFile = "${vs.garage}/environment";
      settings = {
        # todo: not 1?
        replication_mode = 1;

        dataDir = "${config.fileSystems.nas.mountPoint}/minio";

        s3_api = {
          s3_region = "us-east-1";
          api_bind_addr = "[::]:${toString port}";
        };

        s3_web = {
          bind_addr = "[::]:${toString console-port}";
          index = "index.html";
        };
      };
    };
  }
]
