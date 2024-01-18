{ config, ... }:
let
  port = config.custom.networking.proxy."req.donsz.nl".port;
in
{
  config.networking.firewall.allowedTCPPorts = [ port ];

  config.virtualisation.oci-containers.containers = {
    overseerr = {
      image = "mirror.gcr.io/fallenbagel/jellyseerr:develop";
      environment = {
        PORT = "5555";
        TZ = "Europe/Amsterdam";
        LOG_LEVEL = "debug";
      };
      extraOptions = [ "--network=host" ];
      volumes = [
        "/var/lib/microvms/rr/storage/data/overseerr:/app/config"
      ];
    };
  };
}
