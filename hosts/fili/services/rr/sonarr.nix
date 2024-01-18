{ ... }: {
  services.sonarr = {
    enable = true;
    group = "jellyfin";
    user = "jellyfin";
  };
}
