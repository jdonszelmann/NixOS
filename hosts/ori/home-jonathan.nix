{ config, pkgs, inputs, ... }: rec {
  imports = [ ./gnome.nix ];

  programs.home-manager.enable = true;
  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";

  home.packages = with pkgs; [
    element-desktop
    atuin
    discord-canary
    comma
    rustup
    vscode
    spotify
    firefox
    syncthing
    nixfmt
  ];

  programs.vscode = {
    enable = true;
    extensions =
      with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
        rust-lang.rust-analyzer
        jnoortheen.nix-ide
        vscodevim.vim
      ];

    userSettings = {
      "editor.mouseWheelZoom" = true;
      "editor.formatOnSave" = true;
      "vim.useSystemClipboard" = true;
      "window.zoomLevel" = 1;
      "git.openRepositoryInParentFolders" = "never";
      "nix.formatterPath" = "nixfmt";
    };
  };

  programs.firefox = { enable = true; };

  services.syncthing = { enable = true; };

  programs.git = {
    enable = true;
    extraConfig = { init.defaultBranch = "main"; };
    aliases = {

    };
    userName = "Jonathan Dönszelmann";
    userEmail = "jonabent@gmail.com";
  };
}
