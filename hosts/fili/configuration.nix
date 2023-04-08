{ inputs, config, pkgs, ... }:
let
  app = import ./container.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ./apps
  ];

  environment.systemPackages = with pkgs; [ nfs-utils ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
  };


  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };

  # use systemd-boot as bootloader
  boot.loader.systemd-boot.enable = true;
  networking.hostName = "fili";
  system.stateVersion = "22.11";

}
