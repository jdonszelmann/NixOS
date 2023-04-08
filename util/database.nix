{ nixpkgs, ... }: with builtins; with { lib = (nixpkgs.lib); }; let in
{ name, ... }@args: assert isString name;
let
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
    username = args.username or name;
    name = name;

    # no password is set up
    password = "";

    # these are always the same on the system
    port = if (args.type or "mysql" == "postgres") then 5432 else 3306;
    host = args.host or "localhost";
  };

  # specifics of createDbEnv.
  getDbEnvOptions = env: database:
    # TODO: check that there are no other envvars / assert for misspellings
    { ${env.name or null} = database.name; } //
    { ${env.port or null} = database.port; } //
    { ${env.host or null} = database.host; } //
    { ${env.username or null} = database.username; } //
    { ${env.password or null} = database.password; };

  dbType = args.type or "mysql";
  config = createDbConfig args;
  env = getDbEnvOptions (args.env or { }) config;
in
(
  config //
  {
    inherit env;
    create = {
      # if we need to make a postgres database? do so. Mutually exclusive with mysql
      services.postgresql = lib.mkIf (dbType == "postgres") (createPostgresDb config);
      # if we need to make a mysql database? do so. Mutually exclusive with postgres
      services.mysql = lib.mkIf (dbType == "mysql" || dbType == "mariadb") (createMysqlDb config);
    };
  }
)
