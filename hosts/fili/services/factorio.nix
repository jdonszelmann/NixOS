{ config
, pkgs
, microvm
, inputs
, master
, ...
}:
let
  host-data = config.custom.networking.host.factorio;
  ip = host-data.ip;
  port = 34197;
in
{
  #   networking.firewall.extraCommands = "iptables -I FORWARD -p udp --dport ${toString port} -j DNAT --to-destination ${ip}:${toString port}";
  #   networking.firewall.extraStopCommands = "iptables -D FORWARD -p udp --dport ${toString port} -j DNAT  --to-destination ${ip}:${toString port} || true";

  #   microvm.vms.factorio = {
  # inherit pkgs;
  # specialArgs = { inherit inputs; outer-config = config; };
  # config = { ... }: {
  #   imports = [ ../vms/default-vm-config.nix ];
  #   system.stateVersion = config.system.stateVersion;

  services.factorio = {
    package = pkgs.factorio-headless-experimental;
    requireUserVerification = false;
    public = false;
    lan = false;

    username = "jonay2000";
    token = "3bf4f66e585b52fdd2d6b4488bb1d2";
    game-password = "1123581321";
    game-name = "Jonathan Dönszelmann";

    enable = true;
    stateDirName = "factorio";
    saveName = "game1";
    admins = [ "jonay2000" ];
    inherit port;
  };

  #   microvm.shares = [
  # {
  #   source = "/var/lib/microvms/${config.networking.hostName}/factorio";
  #   mountPoint = "/var/lib/factorio";
  #   tag = "factorio";
  #   proto = "virtiofs";
  # }
  #   ];
  # 
  networking.firewall.allowedUDPPorts = [ port ];
  # };
  # };
}
