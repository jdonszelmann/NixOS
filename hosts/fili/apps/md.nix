{ util, lib, config, ... }:
let
  vs = config.vault-secrets.secrets;
  domain = "md.donsz.nl";
  port = util.randomPort domain;
  database = util.database {
    name = "hedgedoc";
    type = "postgres";
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
      # enable = true;
      # environmentFile = "${vs.markdown}/environment";
      # settings = {
      #   host = "0.0.0.0";
      #   port = port;
      #   sessionSecret = "$SESSION_SECRET";
      #   domain = domain;
      #   protocolUseSSL = true;
      #   hsts.enable = true;
      #   allowOrigin = [
      #     domain
      #     "hedgedoc"
      #   ];
      #   email = true;
      #   allowAnonymous = false;
      #   allowEmailRegister = true;
      #   allowAnonymousEdits = true;
      #   allowFreeURL = true;
      #   requireFreeURLAuthentication = true;
      #   imageUploadType = "minio";
      #   logLevel = "debug";
      #   db = {
      #     dialect = "postgres";
      #     username = database.username;
      #     database = database.name;
      #     password = database.password;
      #     host = "localhost";
      #   };
      #   # dbURL = "postgres://${database.username}:${database.password}@${database.host}:${toString database.port}/${database.name}";
      #   s3bucket = "markdown";
      #   minio = {
      #     secure = true;
      #     endPoint = "s3.donsz.nl";
      #     port = 443;
      #     accessKey = "$MINIO_ACCESS_KEY";
      #     secretKey = "$MINIO_SECRET_KEY";
      #   };
      # };
    };
  }
]
