{ util, lib, config, ... }:
let
  vs = config.vault-secrets.secrets;
  database = util.database
    {
      name = "mapfprod";
      type = "mariadb";
      env = {
        name = "MAPF_DBDATABASE";
        username = "MAPF_DBUSER";
        password = "MAPF_DBPASSWORD";
        port = "MAPF_DBPORT";
        host = "MAPF_DBHOST";
        docker = true;
      };
    };
in
lib.mkMerge [
  database.create
  {
    vault-secrets.secrets.mapf-prod = { };
  }
  (util.standardContainer {
    domain = "mapf.nl";
    name = "mapf";
    image = "docker.donsz.nl/mapf";
    port = 8080;
    env = database.env // {
      MAPF_SECRET = "${vs.mapf-prod}/session-secret";
    };
  })
]
