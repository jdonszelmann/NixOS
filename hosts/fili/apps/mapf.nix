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
       (import (inputs.colmena + "/src/nix/hive/eval.nix") {
          rawFlake = self;
          colmenaOptions =
            import (inputs.colmena + "/src/nix/hive/options.nix");
          colmenaModules =
            import (inputs.colmena + "/src/nix/hive/modules.nix");
        }).nodes;
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
