{ util, lib, config, ... }:
let
  domain = "s.donsz.nl";
in
lib.mkMerge [
  (util.standardContainer {
    inherit domain;
    name = "short";
    image = "docker.donsz.nl/short";
    port = 3000;
    env = {
      DB_LOCATION = "/store/store.db";
      BASE_URL = domain;
    };
    volumes = [ "/storage/short:/store" ];
  })
]
