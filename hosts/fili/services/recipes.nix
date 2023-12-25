{ util, lib, config, ... }:
let
  vs = config.vault-secrets.secrets;
  proxy = import ./reverse-proxy-data.nix;
in
{
  vault-secrets.secrets.recipes = {
    services = [ "tandoor-recipes" ];
  };
  services.tandoor-recipes = {
    enable = true;
    port = proxy.recipes.port;
    address = "0.0.0.0";
    extraConfig = {
      TIMEZONE = "Europe/Amsterdam";
      DB_ENGINE = "django.db.backends.postgresql";
      POSTGRES_HOST = "127.0.0.1";
      POSTGRES_PORT = "5432";
      POSTGRES_USER = "recipes";
      POSTGRES_PASSWORD = "";
      POSTGRES_DB = "recipes";
      GUNICORN_MEDIA = 1;
    };
  };
  systemd.services.recipes.serviceConfig.EnvironmentFile = "${vs.recipes}/environment";
}

