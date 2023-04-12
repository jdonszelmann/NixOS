{ config, lib, pkgs, modulesPath, ... }:
let
  directory = "/storage";
  nas = "${directory}/nas";
in
{
  fileSystems.nas = {
    mountPoint = "${nas}";
    device = "192.168.0.8:/Backups";
    fsType = "nfs";
    options = [
      "nfsvers=3"
      "fsc"
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
    "d ${directory} 0770 root ${config.users.groups.storage.name}"
  ];


  users.groups.storage = {
    name = "storage";
    members = [ config.users.users.jonathan.name ];
  };
}
