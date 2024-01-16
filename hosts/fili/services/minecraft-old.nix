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

  worlds = {
    pvpixel = "${directory}/worlds/pvpixel";
    redstone = "${directory}/worlds/redstone";
    survival = "${directory}/worlds/survival";
  };
  world = worlds.survival;

  createWhitelist = users: with builtins;
    listToAttrs (map
      (user: {
        name = user.username;
        value = user.uuid;
      })
      users);

  whitelist = with users; [
    # jonathan-brouwer
    # jonathan
    # julia
  ];
in
{
  services.minecraft-server = {
    enable = true;
    declarative = true;

    # package = pkgs.papermc;
    # package = pkgs.legacyFabricServers.legacy-fabric-1_12_2;
    # package = pkgs.paperServers.paper-1_12_2;

    whitelist = createWhitelist whitelist;

    serverProperties = {
      server-port = port;
      difficulty = 0;
      gamemode = 0;
      max-players = 8;
      motd = "Minecraft server!";
      white-list = (builtins.length whitelist) != 0;
      enable-rcon = true;
      enable-command-block = true;
      force-gamemode = false;
      allow-flight = true;

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
    ];
  };

  #   systemd.services.download-minacraft-world = {
  #     wantedBy = [ "minecraft-server.service" ];
  #     after = [ "network.target" ];
  #     description = "Start the irc client of username.";
  #     serviceConfig = {
  #       # see systemd man pages for more information on the various options for "Type": "notify"
  #       # specifies that this is a service that waits for notification from its predecessor (declared in
  #       # `after=`) before starting
  #       Type = "notify";
  #       # username that systemd will look for; if it exists, it will start a service associated with that user
  #       User = "username";
  #       # the command to execute when the service starts up 
  #       ExecStart = ''${pkgs.screen}/bin/screen -dmS irc ${pkgs.irssi}/bin/irssi'';
  #       # and the command to execute         
  #       ExecStop = ''${pkgs.screen}/bin/screen -S irc -X quit'';
  #     };
  #   };
}
