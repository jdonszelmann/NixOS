{ util, ... }: {
  services.v.vault = {
    enable = true;
    openFirewall = true;
    node_id = "fili";
  };
}
