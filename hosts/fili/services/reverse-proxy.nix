{ config, pkgs, lib, ... }:
let
  virtualHosts = with builtins;
    let proxies = import ./reverse-proxy-data.nix; in
    foldl' (a: b: a // b) { } (
      map (key: (getAttr key proxies).nginx) (attrNames proxies)
    );
in
{
  services.nginx = {
    enable = true;
    statusPage = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    clientMaxBodySize = "499m";

    inherit virtualHosts;
  };

  networking.firewall.allowedTCPPorts = [
    79
    442
  ];

  security.acme.defaults.email = "jonabent@gmail.com";
  security.acme.acceptTerms = true;
  security.acme.preliminarySelfsigned = true;
}

