{ util, lib, config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
  domain = "s3.donsz.nl";
  console-domain = "s3c.donsz.nl";
  rpc-domain = "s3r.donsz.nl";
  port = util.randomPort domain;
  console-port = util.randomPort console-domain;
  rpc-port = util.randomPort rpc-domain;
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

    services.custom-garage = {
      enable = true;
      package = pkgs.donsz.garage_0_8_2;
      environmentFile = "${vs.garage}/environment";
      settings = {
        # todo: not 1?
        replication_mode = 1;

        rpc_bind_addr = "0.0.0.0:${toString rpc-port}";
        rpc_secret_file = "${vs.garage}/rpc-secret";

        dataDir = "${config.fileSystems.nas.mountPoint}/garage";

        s3_api = {
          s3_region = "us-east-1";
          api_bind_addr = "0.0.0.0:${toString port}";
          root_domain = ".s3.garage";
        };

        s3_web = {
          bind_addr = "0.0.0.0:${toString console-port}";
          index = "index.html";
          root_domain = ".web.garage";
        };
      };
    };
  }
]
