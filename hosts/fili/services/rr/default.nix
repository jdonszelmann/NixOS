{ config, pkgs, inputs, lib, ... }:
let
  inherit (config.system) stateVersion;
in
{
  # sops.secrets.recipes = {
  # sopsFile = ../../../secrets/recipes.env;
  # };
  imports = [
    ./overseerr.nix
    ./radarr.nix
    ./sonarr.nix
  ];

  microvm.vms.torrent =
    let
      host-data = config.custom.networking.host.torrent;
    in
    {
      inherit pkgs;
      specialArgs = { inherit inputs host-data; outer-config = config; };
      config = { config, ... }: {
        imports = [
          ../../vms/default-vm-config.nix
          # ./torrent.nix
        ];
        system.stateVersion = stateVersion;

        microvm.shares = lib.mkForce [
          {
            source = "/var/lib/microvms/${config.networking.hostName}/storage";
            mountPoint = "/";
            tag = "root";
            proto = "virtiofs";
          }
        ];
        #   {
        #     source = "/storage/storage/movies";
        #     mountPoint = "/movies";
        #     tag = "movies";
        #     proto = "virtiofs";
        #   }
        #   {
        #     source = "/storage/storage/shows";
        #     mountPoint = "/shows";
        #     tag = "shows";
        #     proto = "virtiofs";
        #   }
        # ];
      };
    };
}

