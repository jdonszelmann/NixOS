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

  createWhitelist = users: with builtins; listToAttrs (map (user: { name = user.minecraft.username; value = user.minecraft.uuid; }) users);
in
lib.mkMerge [
  {
    services.minecraft-server = {
      enable = true;
      declarative = true;

      package = pkgs.papermc;

      whitelist = with config.users.users; createWhitelist [
        jonathan-brouwer
        jonathan
        julia
      ];

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
      members = with config.users.users; [
        jonathan.name
        julia.name
        jonathan-brouwer.name
      ];
    };
  }
]
