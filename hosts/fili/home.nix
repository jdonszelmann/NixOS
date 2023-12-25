{ config, pkgs, lib, ... }:
let
  # symlink = config.lib.file.mkOutOfStoreSymlink;
  admin-dir = "admin";
in

{
  # home-manager.users.jonathan = {
  #   programs = {
  #     home-manager.enable = true;
  #   };

  #   home = {
  #     file = {
  #       "${admin-dir}/secrets".source = symlink "/run/secrets";
  #     };

  #     stateVersion = config.system.stateVersion;
  #   };
  # };
}
