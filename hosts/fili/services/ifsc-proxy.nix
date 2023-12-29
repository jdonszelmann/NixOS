{ util
, lib
, config
, pkgs
, microvm
, inputs
, ...
}:
let
  proxy = import ./reverse-proxy-data.nix;
  stateVersion = config.system.stateVersion;
in
{
  microvm.vms.ifsc-proxy = {
    inherit pkgs;
    specialArgs = { inherit inputs; };
    config = { ... }: {
      imports = [ ../vms/default-vm-config.nix ];
      system.stateVersion = stateVersion;

      services.ifsc-proxy = {
        port = proxy.ifsc-proxy.port;
        enable = true;
      };
      networking.firewall.allowedTCPPorts = [ proxy.ifsc-proxy.port ];
    };
  };
}
