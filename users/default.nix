{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./user-ext.nix
    ./system.nix
    ./jonathan.nix
    ./laura.nix
    ./victor.nix
    ./jonathan_brouwer.nix
    ./julia.nix
  ];

}
