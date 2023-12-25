{ util, lib, config, pkgs, ... }:
let
  proxy = import ./reverse-proxy-data.nix;
in
{
  services.ifsc-proxy = {
    port = proxy.ifsc-proxy.port;
    enable = true;
  };
}
