{ config, pkgs, inputs, ... }:
let
  host-data = config.custom.networking.host.rr;

  inherit (config.system) stateVersion;
in
{
  # sops.secrets.recipes = {
  # sopsFile = ../../../secrets/recipes.env;
  # };

  microvm.vms.rr = {
    inherit pkgs;
    specialArgs = { inherit inputs host-data; outer-config = config; };
    config = { config, ... }: {
      imports = [
        ../../vms/default-vm-config.nix
        ./overseerr.nix
      ];
      system.stateVersion = stateVersion;

      microvm.shares = [
        {
          source = "/var/lib/microvms/${config.networking.hostName}/storage/data";
          mountPoint = "/data";
          tag = "data";
          proto = "virtiofs";
        }
      ];
    };
  };
}

