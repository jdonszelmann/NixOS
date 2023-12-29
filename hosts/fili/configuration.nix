{ inputs, config, pkgs, ... }: {
  imports = [
    inputs.vault-secrets.nixosModules.vault-secrets
    ../../modules
    ./hardware-configuration.nix
    ../default-machine-config.nix
    ./home.nix
    ./storage.nix
    ./services
    ./vms.nix
  ];

  services.qemuGuest.enable = true;

  networking =
    {
      hostName = "fili";
      # can't use cause of vm config
      # nftables.enable = true;
      firewall = {
        enable = true;
        allowedTCPPorts = [
          80
          443
        ];
      };
    };

  nix.settings = {
    # users that can interact with nix
    trusted-users = [
      "jonathan"
      "root"
    ];
  };

  environment.systemPackages = with pkgs; [
    nfs-utils
    # pkgs.vault

    # pkgs.mastodon
    # pkgs.toot
    # pkgs.mcrcon
    # pkgs.linuxPackages_latest.perf
    # pkgs.cargo
    # pkgs.rustc
    # pkgs.matrix-synapse
    # pkgs.donsz.matrix-registration
    # pkgs.pgloader
    # pkgs.hedgedoc
  ];

  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };

  # use systemd-boot as bootloader
  boot.loader.systemd-boot.enable = true;

  # services.fail2ban = {
  #   enable = true;
  #   maxretry = 10;
  # };
}
