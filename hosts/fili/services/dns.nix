{ ... }: with builtins;
let
  proxy = import ./reverse-proxy-data.nix;
  host-data = import ../vms/host-data.nix;
  host-names = attrNames host-data;
  hosts = map
    (host-name: {
      inherit (host-data.${host-name}) ip;
      domain = "${host-name}";
    })
    host-names;
in
{
  services.resolved.enable = false;

  services.custom.dns = {
    enable = true;
    openFirewall = true;
    inherit hosts;
    mode = "server";
  };
}

