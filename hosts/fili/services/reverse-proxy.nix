{ config, pkgs, lib, ... }: {
  services.nginx = {
    enable = true;
    statusPage = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    clientMaxBodySize = "499m";
  };

  networking.firewall.allowedTCPPorts = [
    79
    442
  ];

  security.acme.defaults.email = "jonabent@gmail.com";
  security.acme.acceptTerms = true;
  security.acme.preliminarySelfsigned = true;
}

