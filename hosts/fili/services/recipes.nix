{ config, pkgs, inputs, ... }:
let
  proxy = config.custom.networking.proxy;
  port = proxy."recipes.donsz.nl".port;

  inherit (config.system) stateVersion;
in {
  sops.secrets.recipes = { sopsFile = ../../../secrets/recipes.env; };

  networking.firewall.allowedTCPPorts = [ port ];
  services.tandoor-recipes = {
    enable = true;
    port = port;
    address = "0.0.0.0";
    extraConfig = {
      TIMEZONE = "Europe/Amsterdam";
      DB_ENGINE = "django.db.backends.postgresql";
      POSTGRES_HOST = "localhost";
      POSTGRES_PORT = "5432";
      POSTGRES_USER = "recipes";
      POSTGRES_PASSWORD = "";
      POSTGRES_DB = "recipes";
      GUNICORN_MEDIA = 1;
    };
  };
  systemd.services.recipes.serviceConfig.EnvironmentFile =
    "/run/secrets/recipes.env";
}

