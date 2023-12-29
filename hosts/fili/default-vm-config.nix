{ lib, ... }: {
  imports = [
    ../default-machine-config.nix
  ];
  environment.noXlibs = lib.mkForce false;

  microvm.hypervisor = "crosvm";
  microvm.guest.enable = true;
  microvm.shares = [{
    source = "/nix/store";
    mountPoint = "/nix/.ro-store";
    tag = "ro-store";
    proto = "virtiofs";
  }];
}
