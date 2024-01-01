{ lib, config, ... }:
let
  proxy = import ./reverse-proxy-data.nix;
in
{
  sops.secrets.minio = {
    sopsFile = ../../../secrets/minio.env;
  };

  services.minio = {
    enable = true;
    rootCredentialsFile = "/run/secrets/sops/minio";
    listenAddress = ":${toString proxy.minio.port}";
    consoleAddress = ":${toString proxy.minio-control.port}";
    dataDir = [
      "${config.fileSystems.nas.mountPoint}/minio"
    ];
  };
}
