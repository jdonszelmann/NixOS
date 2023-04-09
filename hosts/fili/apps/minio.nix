{ util, lib, config, ... }:
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
    vault-secrets.secrets.minio = { };

    services.minio = {
      enable = true;
      rootCredentialsFile = "${vs.minio}/environment";
      listenAddress = ":${toString port}";
      consoleAddress = ":${toString console-port}";
      dataDir = [
        "/storage/minio"
      ];
    };
  }
]
