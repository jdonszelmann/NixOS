{ inputs, config, pkgs, ... }:
let
  networking = import ./networking.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ./apps
  ];

  environment.systemPackages = with pkgs; [
    nfs-utils
    pkgs.vault
    direnv
    nix-direnv
  ];

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];
  # if you also want support for flakes
  nixpkgs.overlays = [
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; })
  ];

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
  networking.hostName = networking.hostName;
  system.stateVersion = "22.11";

}
