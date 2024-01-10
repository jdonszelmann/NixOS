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
  # so unbound doesn't suddenly stop while we're requesting certificates.... Then everything breaks.
  systemd.services."acme-fixperms".wants = [ "unbound.service" ];
  systemd.services."acme-fixperms".after = [ "unbound.service" ];

  services.custom.dns = {
    enable = true;
    openFirewall = true;
    inherit hosts;
    mode = "server";
  };
}

