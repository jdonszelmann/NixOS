{ util, lib, config, pkgs, ... }:
let
  domain = "ifsc.donsz.nl";
  port = util.randomPort domain;
  reverse-proxy = util.reverse-proxy {
    from = domain;
    to = port;
  };
in
lib.mkMerge [
  reverse-proxy.create
  {
    services.ifsc-proxy = {
      inherit port;
      enable = true;
    };
  }
]
