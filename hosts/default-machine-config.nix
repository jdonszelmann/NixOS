{ lib, pkgs, inputs, ... }: {
  imports = [
    ./users.nix
    ../modules
    ./cli-programs
    # inputs.home-manager.nixosModules.home-manager
  ];

  system.stateVersion = "24.05";
  services.resolved.enable = false;

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Setup packages available everywhere
  environment.systemPackages = with pkgs; [
    fzf
    git
    htop
    ncdu
    psmisc
    ripgrep
    rsync
    tmux
    zoxide
    tmux
    direnv
    atuin
  ];

  # Set up direnv
  programs.direnv = {
    package = pkgs.direnv;
    silent = false;
    loadInNixShell = true;
    direnvrcExtra = "";
    nix-direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };
  };

  # Install Neovim and set it as alias for vi(m)
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # Disable sudo prompt for `wheel` users.
  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  # Configure the root account
  users.extraUsers.root = {
    # Allow my SSH keys for logging in as root. TODO: find from users list
    # openssh.authorizedKeys.keys = ;

    # Also use zsh for root
    shell = pkgs.zsh;
  };

  services.qemuGuest.enable = true;

  # Clean /tmp on boot.
  boot.tmp.cleanOnBoot = true;

  # Set your time zone.
  time.timeZone = lib.mkDefault "Europe/Amsterdam";

  systemd.oomd = {
    enableRootSlice = true;
    # enableUserServices = true;
    enableUserSlices = true;
  };

  # Limit the systemd journal to 100 MB of disk or the
  # last 7 days of logs, whichever happens first.
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxFileSec=7day
  '';

  nix = {
    package = pkgs.nixFlakes;
    settings = { auto-optimise-store = true; };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      randomizedDelaySec = "3h";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Debloat
  documentation = {
    enable = lib.mkForce false;
    doc.enable = lib.mkForce false;
    man.enable = lib.mkForce false;
    info.enable = lib.mkForce false;
    nixos.enable = lib.mkForce false;
  };

  # home-manager = {
  #   useGlobalPkgs = true;
  #   useUserPackages = true;
  #   verbose = true;
  #   extraSpecialArgs = { inherit inputs; };
  # };
}
