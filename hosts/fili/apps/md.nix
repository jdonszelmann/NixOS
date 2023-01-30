{ app, ... }: app.new rec {
  domain = "md.donsz.nl";
  port = { host = 80; app = 8000; };
  image = "linuxserver/hedgedoc";
  database = {
    type = "mariadb";
    env = {
      name = "DB_NAME";
      port = "DB_PORT";
      user = "DB_USER";
      password = "DB_PASS";
      host = "DB_HOST";
    };
  };
  env = {
    TZ = "Europe/London";
    CMD_DOMAIN = domain;
    CMD_PROTOCOL_USESSL = false;
    CMD_PORT = 8000;
  };
}
