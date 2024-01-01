{ config
, pkgs
, microvm
, inputs
, ...
}:
let
  proxy = import ./reverse-proxy-data.nix;
in
{
  microvm.vms.ifsc-proxy = {
    inherit pkgs;
    specialArgs = { inherit inputs; };
    config = { ... }: {
      imports = [ ../vms/default-vm-config.nix ];
      system.stateVersion = config.system.stateVersion;

      services.ifsc-proxy = {
        inherit (proxy.ifsc-proxy) port;
        enable = true;
      };
      networking.firewall.allowedTCPPorts = [ proxy.ifsc-proxy.port ];
    };
  };
}
