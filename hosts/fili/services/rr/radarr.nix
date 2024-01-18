{ host-data, ... }: {
  services.radarr = {
    enable = true;
    group = "jellyfin";
    user = "jellyfin";
  };
}

