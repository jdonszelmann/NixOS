{ util, pkgs, inputs, ... }:
let
  domain = "vault.donsz.nl";
  port = 8200;
  cluster_port = 8201;
  node_id = "fili";
  # TODO: set somewhere else
  localIp = "192.168.0.59";
  # TODO: set somewhere else
  hostName = "fili";

  key_file = "/var/lib/vault-unseal/keys.json";
in
{
  networking.firewall.allowedTCPPorts = [ port cluster_port ];

  services.vault = {
    enable = true;
    # bin version includes the UI
    package = pkgs.vault-bin;
    address = "${localIp}:${toString port}";
    storageBackend = "raft";
    storagePath = "/var/lib/vault-raft";
    storageConfig = ''
      node_id = "${node_id}"
    '';
    extraConfig = ''
      ui = true
      disable_mlock = true
      api_addr = "http://${localIp}:${toString port}"
      cluster_addr = "http://${localIp}:${toString cluster_port}"
    '';
  };

  vault-secrets = {
    vaultPrefix = "${hostName}_secrets";
    vaultAddress = "http://${localIp}:8200";
    approlePrefix = hostName;
  };

  systemd.services.vault-unseal = {
    description = "Vault unseal service";
    wantedBy = [ "multi-user.target" ];
    after = [ "vault.service" ];
    environment = {
      VAULT_ADDR = "http://${localIp}:${toString port}";
      VAULT_KEY_FILE = key_file;
    };
    serviceConfig = {
      User = "vault";
      Group = "vault";
      Type = "simple";
      Restart = "on-failure";
      ExecStart = "${
            inputs.vault-unseal.packages.${pkgs.system}.default
          }/bin/vault-unseal";
    };
  };
}
