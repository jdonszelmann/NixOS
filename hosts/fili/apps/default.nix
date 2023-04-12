{ pkgs, libs, ... }: {
  imports = [
    ../../../modules
    ./vault.nix
    ./databases.nix
    ./nginx.nix
    ./md.nix
    ./matrix.nix
    ./minio.nix
    ./mastodon.nix
    ./mapf.nix
    ./docker-registry.nix
    ./harmonica.nix
    ./short.nix
    ./research-project.nix
    ./mc.nix
  ];
}
