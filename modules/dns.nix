{ config, pkgs, lib, flat_hosts, ... }:
# DNS Module to set up Unbound DNS with all my hosts in the config
# Used for DNS Servers and my laptop
with lib; with builtins; with types;
let
  cfg = config.services.custom.dns;

  domains = map ({ domain, ... }: domain) cfg.hosts;
  hosts = cfg.hosts;
  localData = { domain, ip, ... }: ''"${domain}. A ${ip}"'';
  ptrData = { domain, ip, ... }: ''"${ip} ${domain}"'';

  host = submodule {
    options = {
      ip = mkOption
        {
          description = ''
            ip address of the host
          '';
          type = str;
        };
      domain = mkOption
        {
          description = ''
            the domain that should point to this ip
          '';
          type = str;
        };
    };
  };
in
{
  options.services.custom.dns = {
    enable = mkEnableOption "custom.dns";

    hosts = mkOption {
      type = listOf host;
      description = ''
        list of hosts
      '';
    };

    openFirewall = mkOption {
      type = bool;
      default = false;
      description = lib.mdDoc ''
        Whether to open port 53 in the firwall for unbound dns
        And `services.prometheus.exporters.unbound.port` for metrics (if enabled).
      '';
    };

    enableMetrics = mkOption {
      type = bool;
      default = false;
      description = ''
        Enable prometheus metrics
      '';
    };

    mode = mkOption {
      type = enum [ "server" "local" ];
      default = "local";
      description = ''
        Whether to configure the DNS in server mode (listen on all interfaces) or local mode (just on localhost)
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
    services.prometheus.exporters.unbound = mkIf cfg.enableMetrics {
      enable = true;
      inherit (cfg) openFirewall;
      inherit (config.services.unbound) group;
      controlInterface = config.services.unbound.localControlSocketPath;
    };
    services.unbound = {
      enable = true;
      package = pkgs.custom.unbound;
      localControlSocketPath = mkIf cfg.enableMetrics "/run/unbound/unbound.socket";
      settings = {
        server = mkMerge [
          {
            use-syslog = "yes";
            module-config = ''"validator iterator"'';

            local-zone =
              map (localdomain: ''"${localdomain}}." transparent'') domains;
            local-data = (map localData hosts);
            local-data-ptr = (map ptrData hosts);

            private-address = [
              "127.0.0.0/8"
              "10.0.0.0/8"
              "::ffff:a00:0/104"
              "172.16.0.0/12"
              "::ffff:ac10:0/108"
              "169.254.0.0/16"
              "::ffff:a9fe:0/112"
              "192.168.0.0/16"
              "::ffff:c0a8:0/112"
              "fd00::/8"
              "fe80::/10"
            ];
          }
          (mkIf (cfg.mode == "server") {
            interface-automatic = "yes";
            interface = [ "0.0.0.0" "::0" ];
            access-control = [
              "127.0.0.1/32 allow_snoop"
              "::1 allow_snoop"
              "10.42.0.0/16 allow"
              "127.0.0.0/8 allow"
              "192.168.0.0/23 allow"
              "192.168.2.0/24 allow"
              "::1/128 allow"
            ];
          })
          (mkIf (cfg.mode == "local") {
            interface = [ "127.0.0.1" "::1" ];
            access-control = [ "127.0.0.1/32 allow_snoop" "::1 allow_snoop" ];
          })
        ];
      };
    };
  };
}
