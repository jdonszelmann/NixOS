{ config, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.services.ifsc-proxy;
in
{
  options.services.ifsc-proxy = {
    enable = mkEnableOption "ifsc proxy";

    port = mkOption {
      type = types.int;
      description = lib.mdDoc ''
        The port ifsc-proxy listens on
      '';
    };

  };

  config = mkIf cfg.enable {
    systemd.services.ifsc-proxy = {
      description = "IFSC proxy";
      wantedBy = [ "multi-user.target" ];

      environment = {
        PORT = "${toString cfg.port}";
      };

      serviceConfig = {
        DynamicUser = true;
        Type = "simple";
        Restart = "on-failure";
        ExecStart = "${
            inputs.ifsc-proxy.packages.${pkgs.system}.default
          }/bin/ifc-proxy";
      };
    };
  };
}

