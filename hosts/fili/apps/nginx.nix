{ config, pkgs, libs, ... }:
{
  services.nginx = {
    enable = true;
    statusPage = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    clientMaxBodySize = "499m";
    # TODO: brotli

    # virtualHosts = libs.mk
  };

  security.acme.defaults.email = "jonabent@gmail.com";
  security.acme.acceptTerms = true;
  security.acme.preliminarySelfsigned = true;
}
