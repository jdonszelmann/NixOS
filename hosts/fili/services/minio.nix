{ lib, config, ... }:
let
  proxy = config.custom.networking.proxy;
in
{
  sops.secrets.minio = {
    sopsFile = ../../../secrets/minio.env;
  };

  services.minio = {
    enable = true;
    rootCredentialsFile = "/run/secrets/sops/minio";
    listenAddress = ":${toString  proxy."s3.donsz.nl".port}";
    consoleAddress = ":${toString proxy."s3c.donsz.nl".port}";
    dataDir = [
      "${config.fileSystems.storage.mountPoint}/minio"
    ];
  };
}
