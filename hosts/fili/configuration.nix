{ config, pkgs, ... }:
let
  app = import ./container.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ./apps
  ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
  };

  # use systemd-boot as bootloader
  boot.loader.systemd-boot.enable = true;
  networking.hostName = "fili";
  system.stateVersion = "22.11";
}
