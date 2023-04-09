{ util, pkgs, ... }:
let
  domain = "vault.donsz.nl";
  port = 8200;
  cluster_port = 8201;
  node_id = "fili";
in
{
  networking.firewall.allowedTCPPorts = [ port cluster_port ];

  services.vault = {
    enable = true;
    # bin version includes the UI
    package = pkgs.vault-bin;
    address = "0.0.0.0:${toString port}";
    storageBackend = "raft";
    storagePath = "/var/lib/vault-raft";
    storageConfig = ''
      node_id = "${node_id}"
    '';
    extraConfig = ''
      ui = true
      disable_mlock = true
      api_addr = "http://0.0.0.0:${toString port}"
      cluster_addr = "http://0.0.0.0:${toString cluster_port}"
    '';
  };
}
