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

  inherit (pkgs) lib;
  modDir = ./factorio-mods;
  modList = lib.pipe modDir [
    builtins.readDir
    (lib.filterAttrs (k: v: v == "regular"))
    (lib.mapAttrsToList (k: v: k))
    (builtins.filter (lib.hasSuffix ".zip"))
  ];
  modToDrv = modFileName:
    pkgs.runCommand "copy-factorio-mods" { } ''
      mkdir $out
      cp ${modDir + "/${modFileName}"} $out/${modFileName}
    ''
    // { deps = [ ]; };
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

    mods = builtins.map modToDrv modList;

    enable = true;
    stateDirName = "factorio";
    saveName = "factorissimo";
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
