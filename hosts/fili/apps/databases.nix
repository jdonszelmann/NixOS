{ config, pkgs, libs, ... }:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      # allow local logins
      local all all               trust
      
      # loopback (v4/v6)
      host all all 127.0.0.1/32   trust
      host all all ::1/128        trust

      # and from podman
      host all all 10.88.0.0/16   trust

      # and the local network
      host all all 192.168.0.0/24 trust
    '';
    settings = {
      listen_addresses = "*";
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        # log-error = "/var/log/mysql_err.log";
        bind-address = "0.0.0.0";
      };
    };
  };

  networking = {
    firewall.allowedTCPPorts = [
      # postgres
      5432
      # mariadb
      3306
    ];
  };
}

