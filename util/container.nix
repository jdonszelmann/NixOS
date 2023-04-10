{ nixpkgs, ... }: with builtins; with { lib = (nixpkgs.lib); }; let
  reverse-proxy = (import ./reverse-proxy.nix).reverse-proxy;
  randomPort = (import ../default.nix).randomPort;
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
      from = "${name}.${domain}";
      hostPort = randomPort from;
      proxy = reverse-proxy
        {
          from = from;
          to = hostPort;
        };
    in
    {

      virtualisation.oci-containers.containers = {
        inherit image;
        ports = [ "127.0.0.1:${toString hostPort}:${toString port}" ];
        config = {
          hostName = name;
        };
        environment = env;
        cmd = lib.mkIf (args ? cmd) args.cmd;
        volumes = volumes;
      };
    };
}
