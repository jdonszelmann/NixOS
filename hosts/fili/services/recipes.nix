{ config, pkgs, inputs, ... }:
let
  host-data = config.custom.networking.host.ifsc-proxy;
  port = host-data.proxy."ifsc-proxy.donsz.nl".port;

  inherit (config.system) stateVersion;
in
{
  sops.secrets.recipes = {
    sopsFile = ../../../secrets/recipes.env;
  };

  microvm.vms.recipes = {
    inherit pkgs;
    specialArgs = { inherit inputs; outer-config = config; };
    config = { config, ... }: {
      imports = [ ../vms/default-vm-config.nix ];
      system.stateVersion = stateVersion;

      networking.firewall.allowedTCPPorts = [ port ];
      services.tandoor-recipes = {
        enable = true;
        port = port;
        address = "0.0.0.0";
        extraConfig = {
          TIMEZONE = "Europe/Amsterdam";
          DB_ENGINE = "django.db.backends.postgresql";
          POSTGRES_HOST = "10.0.0.1";
          POSTGRES_PORT = "5432";
          POSTGRES_USER = "recipes";
          POSTGRES_PASSWORD = "";
          POSTGRES_DB = "recipes";
          GUNICORN_MEDIA = 1;
        };
      };
      systemd.services.recipes.serviceConfig.EnvironmentFile = "/run/secrets/recipes.env";
    };
  };
}

