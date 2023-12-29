{ util
, lib
, config
, pkgs
, microvm
, ...
}:
let
  proxy = import ./reverse-proxy-data.nix;
  stateVersion = config.system.stateVersion;
in
{

  microvm.vms = {
    ifsc-proxy = {
      inherit pkgs;
      config = { ... }: {
        imports = [
          ../default-vm-config.nix
        ];
        system.stateVersion = stateVersion;
        microvm.interfaces = [
          {
            type = "tap";
            id = "vm-ifsc-proxy";
            mac = "02:00:00:00:00:01";
          }
        ];

        systemd.network = {
          enable = true;
          networks."20-ether" = {
            matchConfig.Type = "ether";
            networkConfig = {
              Address = [ "10.0.0.2/24" ];
              Gateway = "10.0.0.1";
              DNS = [ "1.1.1.1" ];
              DHCP = "no";
            };
            linkConfig.ActivationPolicy = "always-up";
          };
        };



        networking.hostName = "ifsc-proxy";
      };
    };
  };



  services.ifsc-proxy = {
    port = proxy.ifsc-proxy.port;
    enable = true;
  };
}
