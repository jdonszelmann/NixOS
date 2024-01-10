{ config, pkgs, inputs, lib, ... }:
let
  host-data = config.custom.networking.host.jellyfin;
  port = host-data.proxy."media.donsz.nl".port;

  inherit (config.system) stateVersion;
in
{
  # TODO: run in vm (with graphics passthrough)
  #   microvm.vms.jellyfin = {
  # inherit pkgs;
  # specialArgs = { inherit inputs; outer-config = config; };
  # config = { config, ... }: {
  #   imports = [ ../vms/default-vm-config.nix ];
  #   system.stateVersion = stateVersion;

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  users.groups.jellyfin = { };
  users.users.jellyfin = {
    isSystemUser = true;
    group = "jellyfin";

    extraGroups = [ "storage" ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jellyfin";
    group = "jellyfin";
  };

  hardware.opengl = {
    enable = true;
    package = pkgs.intel-media-driver;
  };
  systemd.services.jellyfin = {
    # if EncoderAppPath is manually set in the web UI, it can never be updated through --ffmpeg
    preStart = "test ! -e /var/lib/jellyfin/config/encoding.xml || sed -i '/<EncoderAppPath>/d' /var/lib/jellyfin/config/encoding.xml";
    serviceConfig = {
      # allow access to GPUs for hardware transcoding
      DeviceAllow = lib.mkForce "char-drm";
      BindPaths = lib.mkForce "/dev/dri";
      # to allow restarting from web ui
      Restart = lib.mkForce "always";

      Slice = "mediaplayback.slice";
    };
  };
  # };
  #   };
}

