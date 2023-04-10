{ util, lib, config, ... }:
lib.mkMerge [
  (util.standardContainer {
    domain = "mapfm-poster.jdonszelmann.nl";
    name = "mapfm_poster";
    image = "docker.donsz.nl/mapfm_poster";
    port = 8080;
  })
]
