{ util, lib, config, ... }:
let
  vs = config.vault-secrets.secrets;
  domain = "docker.donsz.nl";
  port = util.randomPort domain;
  reverse-proxy = util.reverse-proxy {
    from = domain;
    to = port;
  };
  redisPort = util.randomPort "docker.redis";
in
lib.mkMerge [
  reverse-proxy.create
  {
    vault-secrets.secrets.docker-registry = { };

    # services.redis.servers.docker = {
    #   enable = true;
    #   port = redisPort;
    #   bind = "localhost";
    # };

    services.dockerRegistry = {
      enable = true;
      inherit port;
      listenAddress = "0.0.0.0";
      extraConfig =
        {
          http.secret = "${vs.docker-registry}/session-secret";
        };
      # TODO: redis doesn't seem to work
      #   redisUrl = "localhost:${toString redisPort}";
      #   enableRedisCache = true;

      storagePath = "/storage/docker-registry";
    };
  }
]

