{ config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../default-machine-config.nix
  ];

  environment.systemPackages = with pkgs; [
    gnome.gnome-terminal
    gnome.adwaita-icon-theme
    llvmPackages.bintools
  ];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.jonathan = { ... }: {
    imports = [ ./home-jonathan.nix ];
    home.stateVersion = config.system.stateVersion;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ori"; # Define your hostname.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  # programs.steam.package = pkgs.steam.override {
  #   withPrimus = true;
  #   extraPkgs = pkgs: with pkgs; [ bumblebee glxinfo ];
  # };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    curl
    expat
    fontconfig
    freetype
    fuse
    fuse3
    glib
    icu
    libclang.lib
    libdbusmenu
    libxcrypt-legacy
    libxml2
    nss
    openssl
    python3
    stdenv.cc.cc
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.libXtst
    xz
    zlib
  ];
}

