{ config, pkgs, ... }: rec {
  imports = [
    ./gnome.nix
  ];

  programs.home-manager.enable = true;
  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";
}
