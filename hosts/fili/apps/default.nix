{ pkgs, libs, ... }: {
  imports = [
    ./vault.nix
    ./databases.nix
    ./nginx.nix
    ./md.nix
    ./matrix.nix
    ./garage.nix
    ./mastodon.nix
    ./mapf.nix
    ./docker-registry.nix
    ./harmonica.nix
    ./short.nix
    ./research-project.nix
  ];

  # make nix containers work
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "ens18";
  };
}
