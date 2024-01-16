{ host-data, ... }:
let
  overseerr-port = host-data.proxy."req.donsz.nl".port;
in
{
  config.networking.firewall.allowedTCPPorts = [ overseerr-port ];

  config.virtualisation.oci-containers.containers = {
    overseerr = {
      image = "sctx/overseerr:1.33.2";
      environment = {
        PORT = "5555";
        TZ = "Europe/Amsterdam";
        LOG_LEVEL = "debug";
      };
      ports = [
        "5555:${toString overseerr-port}"
      ];
      volumes = [
        "/data/overseerr:/app/config"
      ];
      extraOptions = [ "--restart unless-stopped" ];
    };
  };
}
