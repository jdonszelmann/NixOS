{ config, pkgs, libs, ... }:
{
  services.nginx = {
    enable = true;
    statusPage = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    clientMaxBodySize = "500m";

    # TODO: brotli
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    2049 # nfs
  ];

  security.acme.defaults.email = "jonabent@gmail.com";
  security.acme.acceptTerms = true;
  security.acme.preliminarySelfsigned = true;
}
