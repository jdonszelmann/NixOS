{ config, pkgs, ... }: rec {
  imports = [
    ./gnome.nix
  ];

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
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      jnoortheen.nix-ide
    ];
  };

  programs.firefox = {
    enable = true;
  };

  services.syncthing = {
    enable = true;
  };
}
