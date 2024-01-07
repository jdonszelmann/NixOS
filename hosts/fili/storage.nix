{ config, lib, pkgs, modulesPath, ... }:
let
  directory = "/storage";
  nas = "${directory}/nas";

  storage = "${directory}/storage";
in
{
  fileSystems.nas = {
    mountPoint = "${nas}";
    device = "192.168.0.8:/Backups";
    fsType = "nfs4";
    options = [
      "fsc"
      "sync=disabled"
      "ro"
    ];
  };


  boot.swraid.enable = true;
  boot.swraid.mdadmConf = ''
    ARRAY /dev/md0 metadata=1.2 name=fili:0 UUID=0796fee2:0d9f2908:24af61b0:1250fa0e
  '';
  fileSystems.storage = {
    mountPoint = "${storage}";
    device = "/dev/md0";
    fsType = "btrfs";
    options = [
      "compress=zstd"
    ];
  };

  services.cachefilesd = {
    enable = true;
    extraConfig = "
brun 20%
bcull 10%
bstop 5%
    ";
  };

  # don't allow execute permissions for "other" people
  # (not root user and not in storage group)
  # to effectively disallow people outside the storage group
  # to access /storage 
  systemd.tmpfiles.rules = [
    "d ${directory} 0777 root ${config.users.groups.storage.name}"
  ];

  users.groups.storage = {
    name = "storage";
    members = [ config.users.users.jonathan.name ];
  };

  networking.firewall.allowedTCPPorts = [
    2049
  ];
}
