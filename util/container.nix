{ nixpkgs, ... }@inputs: with builtins; with { inherit (nixpkgs) lib; }; let
  inherit ((import ./default.nix inputs)) reverse-proxy;
  inherit ((import ./default.nix inputs)) randomPort;
in
{
  standardContainer =
    { name
    , image
    , domain ? "donsz.nl"
    , port ? 3000
    , env ? { }
    , volumes ? [ ]
    }@args:
    let
      hostPort = randomPort domain;
      proxy = reverse-proxy
        {
          from = domain;
          to = hostPort;
        };
    in
    lib.mkMerge [
      proxy.create
      {
        virtualisation.oci-containers.containers = {
          ${name} = {
            inherit image;
            ports = [ "127.0.0.1:${toString hostPort}:${toString port}" ];
            environment = env;
            cmd = lib.mkIf (args ? cmd) args.cmd;
            inherit volumes;
            extraOptions = [ "--pull=always" ];
          };
        };
      }
    ];
}
