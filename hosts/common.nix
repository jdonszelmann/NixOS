{ inputs, config, pkgs, lib, ... }: {
  imports = [
    ../users
  ];

  # Clean /tmp on boot.
  boot.cleanTmpDir = true;

  # Set your time zone.
  time.timeZone = lib.mkDefault "Europe/Amsterdam";

  # Systemd OOMd
  # Fedora enables these options by default. See the 10-oomd-* files here:
  # https://src.fedoraproject.org/rpms/systemd/tree/acb90c49c42276b06375a66c73673ac3510255
  systemd.oomd = {
    enableRootSlice = true;
    enableUserServices = true;
  };

  # Nix Settings
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "system" "jonathan" ];
      substituters = [
        "https://cachix.cachix.org"
        "https://nix-community.cachix.org"
        "https://colmena.cachix.org"
      ];
      trusted-public-keys = [
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      ];
    };
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

  virtualisation =
    {
      # enable podman
      podman = {
        enable = true;
        dockerCompat = true;
      };
    };

  nixpkgs.config.allowUnfree = true;

  # Limit the systemd journal to 100 MB of disk or the
  # last 7 days of logs, whichever happens first.
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxFileSec=7day
  '';

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
    };
  };

  programs.neovim = {
    enable = true;
    # package = pkgs.neovim-unwrapped;

    # extraPlugins = with pkgs.vimPlugins; [ catppuccin-nvim ];

    # colorscheme = "catppuccin-frappe";

    # plugins = {
    #   nix.enable = true;
    #   treesitter = {
    #     enable = true;
    #     nixGrammars = false;
    #     ensureInstalled = [ ];
    #   };
    #   surround.enable = true;
    #   fugitive.enable = true;
    #   lualine = {
    #     enable = true;
    #     theme = "catppuccin";
    #   };
    #   telescope = {
    #     enable = true;
    #     extensions.fzf-native.enable = true;
    #   };
    #   # lsp = {
    #   #   enable = true;
    #   #   servers.rust-analyzer.enable = true;
    #   #   servers.rnix-lsp.enable = true;
    #   #   servers.pyright.enable = true;
    #   # };
    #   nvim-cmp = { enable = true; };
    # };
  };
}
