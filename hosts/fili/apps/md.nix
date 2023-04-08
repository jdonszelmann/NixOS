{ util, lib, config, ... }:
let
  vs = config.vault-secrets.secrets;
  domain = "md.donsz.nl";
  port = util.randomPort domain;
  database = util.database {
    name = "markdown";
    type = "mysql";
  };
  reverse-proxy = util.reverse-proxy {
    from = domain;
    to = port;
  };
in
lib.mkMerge [
  database.create
  reverse-proxy.create
  {
    vault-secrets.secrets.markdown = { };

    services.hedgedoc = {
      enable = true;
      environmentFile = "${vs.markdown}/environment";
      settings = {
        host = "0.0.0.0";
        port = port;
        # sessionSecret = "$SESSION_SECRET";
        domain = domain;
        protocolUseSSL = true;
        hsts.enable = true;
        allowOrigin = [
          domain
          "hedgedoc"
        ];
        email = true;
        allowAnonymous = false;
        allowEmailRegister = true;
        allowAnonymousEdits = true;
        allowFreeURL = true;
        requireFreeURLAuthentication = true;
        # imageUploadType = "minio";
        db = {
          dialect = "mysql";
          username = database.username;
          database = database.name;
          password = database.password;
          host = "localhost";
        };
        # s3bucket = "hedgedoc";
        # minio = {
        # secure = true;
        # endPoint = "o.0x76.dev";
        # port = 443;
        # accessKey = "$MINIO_ACCESS_KEY";
        # secretKey = "$MINIO_SECRET_KEY";
        # };
      };
    };
  }
]
