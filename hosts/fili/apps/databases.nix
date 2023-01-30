{ pkgs, libs, ... }:
{
  services.postgresql = {
    enable = true;
  };
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
}
