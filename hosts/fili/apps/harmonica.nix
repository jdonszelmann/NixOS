{ util, lib, ... }:
(util.standardContainer {
  domain = "harmonica.donsz.nl";
  name = "harmonica";
  image = "docker.donsz.nl/harmonica";
  port = 8080;
})
