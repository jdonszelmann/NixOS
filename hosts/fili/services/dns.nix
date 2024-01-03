{ config, ... }: with builtins;
let
  host-data = config.custom.networking.host;
  host-names = attrNames host-data;
  hosts = map
    (host-name: {
      inherit (host-data.${host-name}) ip;
      domain = "${host-name}";
    })
    host-names;
in
{
  services.custom.dns = {
    enable = true;
    openFirewall = true;
    inherit hosts;
    mode = "server";
  };
}

