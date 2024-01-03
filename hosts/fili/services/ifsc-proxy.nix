{ config
, pkgs
, microvm
, inputs
, ...
}:
let
  host-data = config.custom.networking.host.ifsc-proxy;
  port = host-data.proxy."ifsc-proxy.donsz.nl".port;
in
{
  microvm.vms.ifsc-proxy = {
    inherit pkgs;
    specialArgs = { inherit inputs; outer-config = config; };
    config = { ... }: {
      imports = [ ../vms/default-vm-config.nix ];
      system.stateVersion = config.system.stateVersion;

      services.ifsc-proxy = {
        inherit port;
        enable = true;
      };
      networking.firewall.allowedTCPPorts = [ port ];
    };
  };
}
