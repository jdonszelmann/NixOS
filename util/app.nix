{ nixpkgs, ... }: with builtins; with { lib = (nixpkgs.lib); }; let
  # randomPort isn't actually a random port. Instead it's basically a hash
  # of the app name
  randomPort = name:
    let
      # take the sha512
      stringHash = hashString "sha512" name;
      nth = i: substring i 1 stringHash;
      # get the first 4 digits
      chars = [ (nth 0) (nth 1) (nth 2) (nth 3) ];
      fromHex = x: {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
      }.${x};
      # convert them from hex
      digits = map fromHex chars;
      # into a single 16 bit number
      res = builtins.foldl' (acc: val: acc * 16 + val) 0 digits;
    in
    # if it's in a nice range, let's go! else let's retry with a '-' added
    if res > 9000 && res < 65000 then res else randomPort (name + "-")
  ;

  # create the config of a docker container
  createDockerContainer = { name, image, port, ... }@args:
    hostPort:
    let
      appPort = if (isInt port) then port else port.app;
      env = mapAttrs (name: value: toString value) (args.env or { });
    in
    assert isInt hostPort;
    assert isInt appPort;
    assert isString image;
    assert isString name;
    {
      ${name} = {
        inherit image;
        ports = [ "127.0.0.1:${toString hostPort}:${toString appPort}" ];
        volumes = [ ];
        cmd = lib.mkIf (args ? cmd) args.cmd;
        environment = env;
      };
    };

  # create the config of a nix container
  createNixContainer = { name, configuration, ... }@args: hostPort:
    let
      database = createDbConfig args;
    in
    assert database != { };
    {
      autoStart = true;
      privateNetwork = false;
      ephemeral = false;

      config = { config, pkgs, ... }@args:
        {


          system.stateVersion = lib.mkDefault "22.11";

          # don't do firewall for the sub-configuration by default,
          # the host can do that
          networking.firewall = lib.mkDefault {
            enable = false;
          };

          # apparently necessary as per the docs? https://nixos.wiki/wiki/NixOS_Containers
          environment.etc."resolv.conf".text = "nameserver 8.8.8.8";
        } // (configuration (args // { inherit database; port = hostPort; }));
    };


  createHostApp = { name, configuration, ... }@args: hostPort:
    let
      database = createDbConfig args;
    in
    assert database != { };
    (configuration (args // {
      inherit database;
      port = hostPort;
    }));

  createPostgresDb = { username, password, name, port, host }: {
    ensureUsers = [{
      name = username;
      ensurePermissions = {
        "DATABASE ${name}" = "ALL PRIVILEGES";
      };
    }];
    ensureDatabases = [ name ];
  };
  createMysqlDb = { username, password, name, port, host }: {
    ensureUsers = [{
      name = username;
      ensurePermissions = {
        # sql inject the right code to create a user not @localhost but @%
        "" = "ALL on ${name}.* TO ${username}@'localhost' IDENTIFIED BY '${password}'; 
        DROP USER '${username}'@'localhost'; 
        FLUSH PRIVILEGES;
        CREATE USER IF NOT EXISTS '${username}'@'%';
        GRANT ALL on ${name}.* TO ${username}@'%' IDENTIFIED BY '${password}'; --";
      };
    }];
    ensureDatabases = [ name ];
  };

  # creates a database configuration to be used by the create<___>Db functions above,
  # or to know what to put in the env for getDbOptions
  createDbConfig = { name, ... }@args: {
    # these can be configured using database.<field>, but default to the name of the app
    username = if args?database && args.database?username then args.database.username else name;
    name = if args?database && args.database?name then args.database.name else name;

    # no password is set up
    password = "";

    # these are always the same on the system
    port = if (needsPostgresDb args) then 5432 else 3306;
    host = "host.containers.internal";
  };

  # specifics of createDbEnv.
  getDbEnvOptions = env: database:
    # TODO: check that there are no other envvars / assert for misspellings
    { ${env.name or null} = database.name; } //
    { ${env.port or null} = database.port; } //
    { ${env.host or null} = database.host; } //
    { ${env.username or null} = database.username; } //
    { ${env.password or null} = database.password; };

  # generate an attr set of ENVVAR=value; to be included in the container's envvars.
  createDbEnv = { ... }@args:
    if (needsDb args) && (needsDbEnv args) then getDbEnvOptions args.database.env (createDbConfig args) else { };


  needsDbEnv = { database, ... }: database?env;
  needsDb = { ... }@args: args ? database;
  needsPostgresDb = { ... }@args: (needsDb args) && args.database.type == "postgres";
  needsMysqlDb = { ... }@args: (needsDb args) && args.database.type == "mysql" || args.database.type == "mariadb";
in
{
  new = { name, domain ? "${name}.donsz.nl", ... }@initialArgs:
    let
      env = (initialArgs.env or { }) // (createDbEnv initialArgs);
      args = initialArgs // { inherit env; };

      hostPort = if (isInt (args.port or 1)) then (randomPort name) else port.host;


      mkWellKnown = data: ''
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '${builtins.toJSON data}';
      '';

      # take all well-knowns or an empty list
      well-knowns = args.well-knowns or [ ];
      # turn them into the right structure
      well-known-attrs = map
        ({ name, config }: {
          "/.well-known/${name}".extraConfig = mkWellKnown config;
        })
        well-knowns;
      # concat them all
      well-known-locations = foldl' (x: y: x // y) { } well-known-attrs;

      # with just the normal nginx locations list
      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString hostPort}";
          proxyWebsockets = true;
        };
      } // well-known-locations;

      implicit_type = if args?image then "podman" else "nix";
      type = args.type or implicit_type;
    in
    builtins.trace (builtins.toJSON env)
      lib.mkMerge [
      {
        # if we need to make a postgres database? do so. Mutually exclusive with mysql
        services.postgresql = lib.mkIf (needsPostgresDb initialArgs) (createPostgresDb (createDbConfig initialArgs));
        # if we need to make a mysql database? do so. Mutually exclusive with postgres
        services.mysql = lib.mkIf (needsMysqlDb initialArgs) (createMysqlDb (createDbConfig initialArgs));

        # if we need to create a nix container? do so. This happens when no image is specified
        containers.${name} = lib.mkIf (type == "nix") (createNixContainer args hostPort);

        # if we need to create a docker container (when an image is specified) do so
        virtualisation.oci-containers.containers = lib.mkIf (type == "podman") (createDockerContainer args hostPort);

        services.nginx = {
          virtualHosts.${domain} = {
            listen = lib.mkIf (args?port) {
              port = args.port;
              address = "0.0.0.0";
            };

            enableACME = true;
            forceSSL = true;

            # put all the locations in the config
            inherit locations;
          };
        };
      }
      (if type == "host" then (createHostApp args hostPort) else { })
    ];
}
