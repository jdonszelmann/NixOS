{ util, pkgs, ... }:
let
  domain = "vault.donsz.nl";
  port = 8200;
  cluster_port = 8201;
  node_id = "fili";
  networking = import ../networking.nix;
in
{
  networking.firewall.allowedTCPPorts = [ port cluster_port ];

  services.vault = {
    enable = true;
    # bin version includes the UI
    package = pkgs.vault-bin;
    address = "${networking.localIp}:${toString port}";
    storageBackend = "raft";
    storagePath = "/var/lib/vault-raft";
    storageConfig = ''
      node_id = "${node_id}"
    '';
    extraConfig = ''
      ui = true
      disable_mlock = true
      api_addr = "http://${networking.localIp}:${toString port}"
      cluster_addr = "http://${networking.localIp}:${toString cluster_port}"
    '';
  };

  vault-secrets = {
    vaultPrefix = "${networking.hostName}_secrets";
    vaultAddress = "http://${networking.localIp}:8200";
    approlePrefix = networking.hostName;
  };
}
