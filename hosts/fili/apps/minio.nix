{ util, ... }: util.app.new rec {
  name = "markdown";
  domain = "s3.donsz.nl";
  database = {
    type = "mysql";
  };
  configuration = { database, port, ... }@args: {
    services.minio = {
      enable = true;
      rootCredentialsFile = "${vs.minio}/environment";
      listenAddress = ":${toString port}";
      consoleAddress = ":${toString 9001}";
    };
  };
}
