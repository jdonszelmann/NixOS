{ nixpkgs, ... }:
let
{
nixContainer = { name, image, port, ... }@args:
  let
    port = if isInt port then port else port.port;
    appPort = if isInt port then port else port.appPort;
  in
  assert isInt port;
  assert isInt appPort;
  assert isString image;
  assert isString name;
  {
    config.virtualisation.oci-containers.containers = {
      ${name} = {
        image = image;
        ports = [ "127.0.0.1:${port}:${appPort}" ];
        volumes = [ ];
        cmd = lib.mkIf args ? cmd [ args.cmd ];
      };
    };
  };
dockerContainer = { name, ... }: {
  containers.${name} = {
    autoStart = true;
    config = {
      hostName = name;
    };
  };
};
new = { ... }@args: if args?image then nixContainer args else dockerContainer args;
}

