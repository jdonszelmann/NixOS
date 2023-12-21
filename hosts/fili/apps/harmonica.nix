{ util, lib, ... }:
(util.standardContainer {
  domain = "harmonica.donsz.nl";
  name = "harmonica";
  image = "docker.donsz.nl/harmonica:latest";
  port = 8080;
})
