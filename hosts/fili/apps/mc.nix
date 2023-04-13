{ util, lib, config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
  domain = "mc.donsz.nl";
  rcon-domain = "mc.donsz.nl";
  port = 25565;
  rcon-port = 25575;
  # TODO: home-manager!
  directory = "/minecraft";
  world = "${directory}/active-world";
in
lib.mkMerge [
  {
    services.minecraft-server = {
      enable = true;
      declarative = true;

      package = pkgs.papermc;

      whitelist = {
        "jonay2000" = "ae528e39-5a10-40f7-84e9-9d15ddaf7c7d"; # Jonathan Dönszelmann
        "Bammerbom" = "27d51a02-1cec-49fa-8afa-4a6aff0e5b0a"; # Jonathan Brouwer
        "Vlamonster" = "99a4315a-24d8-4f82-b9ab-65097957774c"; # Julia
      };

      serverProperties = {
        server-port = port;
        difficulty = 3;
        gamemode = 1;
        max-players = 5;
        motd = "Minecraft server!";
        white-list = true;
        enable-rcon = true;
        "rcon.password" = "not-important";
        "rcon.port" = toString rcon-port;
      };

      jvmOpts = "-Xms8192M -Xmx8192M";

      eula = true;

      dataDir = world;
    };

    networking.firewall.allowedTCPPorts = [
      port
    ];

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
      members = [
        config.users.users.jonathan.name
        config.users.users.julia.name
        config.users.users.jonathan-brouwer.name
      ];
    };
  }
]
