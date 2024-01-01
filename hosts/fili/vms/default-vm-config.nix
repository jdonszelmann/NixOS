{ lib, config, inputs, ... }:
let
  host-data = import ./host-data.nix;
in
{
  networking.firewall.enable = true;
  imports = [
    ../../default-machine-config.nix
  ];
  environment.noXlibs = lib.mkForce false;

  microvm.interfaces = [
    {
      type = "tap";
      id = "vm-${config.networking.hostName}";
      mac = "${host-data.${config.networking.hostName}.mac}";
    }
  ];

  systemd.network = {
    enable = true;
    networks."20-ether" = {
      matchConfig.Type = "ether";
      networkConfig = {
        Address = [ "${host-data.${config.networking.hostName}.ip}/24" ];
        Gateway = "10.0.0.1";
        DNS = [ "1.1.1.1" ];
        DHCP = "no";
      };
      linkConfig.ActivationPolicy = "always-up";
    };
  };

  microvm.hypervisor = "crosvm";
  microvm.guest.enable = true;
  microvm.shares = [
    {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
    }
    # share the etc directory between the host and vm
    {
      source = "/var/lib/microvms/${config.networking.hostName}/storage/etc";
      mountPoint = "/etc";
      tag = "ssh";
      proto = "virtiofs";
    }
    # share /run/secrets with the host for the sops key
    {
      source = "/run/secrets";
      mountPoint = "/run/secrets";
      tag = "secrets";
      proto = "virtiofs";
    }
  ];
}
