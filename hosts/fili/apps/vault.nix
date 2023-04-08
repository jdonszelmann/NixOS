{ util, ... }:
let
  server_name = "jdonszelmann.nl";
in
util.app.new rec {
  name = "matrix";
  domain = "matrix.${server_name}";
  type = "host";

  configuration = { port, ... }@args: {
    services.v.vault = {
      enable = true;
      openFirewall = true;
      node_id = "fili";
    };
  };
}
