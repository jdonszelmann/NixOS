{ pkgs, libs, ... }: {
  imports = [
    ./vault.nix
    ./databases.nix
    ./nginx.nix
    ./md.nix
    ./matrix.nix
    ./minio.nix
  ];

  # make nix containers work
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "ens18";
  };
}
