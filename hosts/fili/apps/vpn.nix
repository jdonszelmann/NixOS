{ lib, config, pkgs, inputs, ... }:
let vs = config.vault-secrets.secrets;
in
{
  imports = [ ];

  networking.firewall.allowedUDPPorts =
    [ config.networking.wireguard.interfaces.wg0.listenPort ];
  networking.firewall.checkReversePath = false;

  vault-secrets.secrets.wireguard = { services = [ "wireguard-wg0" ]; };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "wg0" "eth0" ];
    externalInterface = "eth0";
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "${vs.wireguard}/privateKey";

    peers = [
      # todo: integrate with user config
      {
        # Nori (tv laptop, TU laptop, linux)
        publicKey = "TeKR8jpyT5ameD3h+YTo22ennV/VYi4QK35BipLrWxU=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        # Ori (lenovo ideapad)
        publicKey = "cyfB4FhsMRtqif7O3nrg2o+MdbtY+833AOzkTNlcFkc=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
    ];
  };
}
