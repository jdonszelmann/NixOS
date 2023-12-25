{ pkgs, libs, ... }: {
  imports = [
    ./vault.nix
    ./databases.nix
    ./reverse-proxy.nix
    # ./md.nix
    ./matrix.nix
    # ./minio.nix
    # ./mastodon.nix
    # ./mapf.nix
    # ./docker-registry.nix
    # ./harmonica.nix
    # ./short.nix
    # ./research-project.nix
    ./minecraft.nix
    ./ifsc-proxy.nix
    ./recipes.nix
    # ./vpn.nix
    # ./syncthing.nix
  ];
}
