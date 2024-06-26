{ pkgs, libs, ... }: {
  imports = [
    ./databases.nix
    ./reverse-proxy.nix
    ./jellyfin.nix
    # ./md.nix
    ./matrix.nix
    ./minio.nix
    # ./mastodon.nix
    # ./mapf.nix
    # ./docker-registry.nix
    # ./harmonica.nix
    # ./short.nix
    # ./research-project.nix
    # ./minecraft-gtnh.nix
    # ./minecraft.nix
    ./ifsc-proxy.nix
    ./recipes.nix
    # ./vpn.nix
    ./syncthing.nix
    ./dns.nix
    ./factorio.nix

    # radarr, sonarr, overseerr, etc.
    ./rr
  ];
}
