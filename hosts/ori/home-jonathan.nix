{ config, pkgs, inputs, ... }: rec {
  imports = [ ../programs ];

  programs.home-manager.enable = true;
  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";

  home.packages = with pkgs; [
    element-desktop
    atuin
    discord-canary
    comma
    rustup
    python3
    spotify
    firefox
    syncthing
    nixfmt
    xdg-utils
    # to copy from the command line (my zsh config has an alias `clip` to pipe things to the clipboard)
    wl-clipboard-rs
  ];

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
