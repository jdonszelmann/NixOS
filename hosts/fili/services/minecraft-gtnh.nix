{ util, lib, config, pkgs, ... }:
let
  port = 25565;
  rcon-port = 25515;
  directory = "/minecraft";

  users = {
    jonathan-brouwer = {
      username = "Bammerbom";
      uuid = "27d51a02-1cec-49fa-8afa-4a6aff0e5b0a";
    };
    jonathan = {
      username = "jonay2000";
      uuid = "ae528e39-5a10-40f7-84e9-9d15ddaf7c7d";
    };
    julia = {
      username = "Vlamonster";
      uuid = "99a4315a-24d8-4f82-b9ab-65097957774c";
    };
  };

  worlds = { main = "${directory}/worlds/gtnh-main"; };
  world = worlds.main;

  createWhitelist = users:
    with builtins;
    listToAttrs (map (user: {
      name = user.username;
      value = user.uuid;
    }) users);

  whitelist = with users; [
    # jonathan-brouwer
    jonathan
    julia
  ];
in {
  services.minecraft-server = {
    enable = true;
    declarative = true;

    package = pkgs.custom.gtnh-server;

    # whitelist = createWhitelist whitelist;

    serverProperties = {
      server-port = port;
      difficulty = 3;
      gamemode = 0;
      simulation-distance = 20;
      max-players = 8;
      # white-list = (builtins.length whitelist) != 0;

      enable-rcon = true;
      force-gamemode = false;

      "rcon.password" = "not-important";
      "rcon.port" = toString rcon-port;

      op-permission-level = 2;
      allow-nether = true;
      level-name = "World";
      enable-query = false;
      allow-flight = true;
      announce-player-achievements = true;
      level-type = "rwg";
      max-build-height = 256;
      spawn-npcs = true;
      spawn-animals = true;
      hardcore = false;
      snooper-enabled = true;
      online-mode = true;
      server-id = "unnamed";
      pvp = true;
      enable-command-block = true;
      player-idle-timeout = 0;
      spawn-monsters = true;
      generate-structures = true;
      view-distance = 8;
      spawn-protection = 1;
      motd = "GT New Horizons 2.5.0";
    };

    jvmOpts = "-Xms8192M -Xmx8192M";
    eula = true;
    dataDir = world;
  };
  networking.firewall.allowedTCPPorts = [ port ];

  # don't allow execute permissions for "other" people
  # (not root user and not in storage group)
  # to effectively disallow people outside the minecraft group
  # to access this directory 
  systemd.tmpfiles.rules = [
    "d ${directory} 6770 minecraft ${config.users.groups.minecraft.name}"
    "d ${world} 6770 minecraft ${config.users.groups.minecraft.name}"
  ];

  # Who is allowed to access the minecraft directories?
  users.groups.minecraft = {
    name = "minecraft";
    members = with config.users.users; [ jonathan.name ];
  };

  systemd.sockets.minecraft-server.enable = lib.mkForce false;
  systemd.services.minecraft-server.requires = lib.mkForce [ ];
  systemd.services.minecraft-server.after = lib.mkForce [ "network.target" ];
  systemd.services.minecraft-server.serviceConfig.StandardInput =
    lib.mkForce "null";
}
