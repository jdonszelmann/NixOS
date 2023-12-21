{ util, lib, config, ... }:
let
  vs = config.vault-secrets.secrets;
  domain = "recipes.donsz.nl";
  port = util.randomPort domain;
  reverse-proxy = util.reverse-proxy {
    from = domain;
    to = port;
  };
  database = util.database {
    name = "recipes";
    type = "postgres";
  };
in
lib.mkMerge [
  reverse-proxy.create
  database.create
  {
    vault-secrets.secrets.recipes = {
      services = [ "tandoor-recipes" ];
    };
    services.tandoor-recipes = {
      enable = true;
      inherit port;
      address = "0.0.0.0";
      extraConfig = {
        TIMEZONE = "Europe/Amsterdam";
        DB_ENGINE = "django.db.backends.postgresql";
        POSTGRES_HOST = database.host;
        POSTGRES_PORT = database.port;
        POSTGRES_USER = database.username;
        POSTGRES_PASSWORD = database.password;
        POSTGRES_DB = database.name;
        GUNICORN_MEDIA = 1;
      };
    };
    systemd.services.tandoor-recipes.serviceConfig.EnvironmentFile = "${vs.recipes}/environment";
  }
]

