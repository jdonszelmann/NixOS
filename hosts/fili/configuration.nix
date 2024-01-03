{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.sops-nix.nixosModules.sops

    inputs.microvm.nixosModules.host
    inputs.nix-minecraft.nixosModules.minecraft-servers

    ./hardware-configuration.nix
    ../default-machine-config.nix
    ./home.nix
    ./storage.nix
    ./hosts.nix
    ./vms

    ./services
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

  # for secret unlocking.
  sops.age.keyFile = "/run/secrets/sops-key.txt";
  sops.defaultSopsFormat = "dotenv";
  sops.symlinkPath = "/run/secrets/sops";
}
