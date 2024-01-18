{ config, pkgs, inputs, ... }:
let
  host-data = config.custom.networking.host.rr;

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

  # microvm.vms.rr = {
  #   inherit pkgs;
  #   specialArgs = { inherit inputs host-data; outer-config = config; };
  #   config = { config, ... }: {
  #     imports = [
  #       ../../vms/default-vm-config.nix
  #     ];
  #     system.stateVersion = stateVersion;

  #     users.groups.jellyfin = {
  #       gid = outer-gid;
  #     };
  #     users.users.jellyfin = {
  #       uid = outer-uid;
  #       isSystemUser = true;
  #       group = "jellyfin";

  #       extraGroups = [ "storage" ];
  #     };

  #     microvm.shares = [
  #       {
  #         source = "/var/lib/microvms/${config.networking.hostName}/storage/data";
  #         mountPoint = "/data";
  #         tag = "data";
  #         proto = "virtiofs";
  #       }
  #       {
  #         source = "/storage/storage/movies";
  #         mountPoint = "/movies";
  #         tag = "movies";
  #         proto = "virtiofs";
  #       }
  #       {
  #         source = "/storage/storage/shows";
  #         mountPoint = "/shows";
  #         tag = "shows";
  #         proto = "virtiofs";
  #       }
  #     ];
  #   };
  # };
}

