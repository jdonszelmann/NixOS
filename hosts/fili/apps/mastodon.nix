{ util, lib, config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
  server_name = "jdonszelmann.nl";
  domain = "mastodon.${server_name}";
  port = util.randomPort domain;
  database = util.database {
    name = "mastodon";
    type = "postgres";
  };
  networking = import ../networking.nix;
in
lib.mkMerge [
  database.create
  {
    vault-secrets.secrets.mastodon = {
      services = [ "mastodon-init-dirs" "mastodon" "mastodon-media-prune" ];
      inherit (config.services.mastodon) user group;
    };

    # from https://github.com/NixOS/nixpkgs/blob/619ca2064f709582ef4710be2c18433241adfdd0/nixos/modules/services/web-apps/mastodon.nix#L756
    # (they make some assumptions about the system that don't hold for me)
    services.nginx = {
      recommendedProxySettings = true;

      virtualHosts.${domain} = {
        root = "${config.services.mastodon.package}/public";
        locations."/system/".alias = "/var/lib/mastodon/public-system/";
        forceSSL = lib.mkDefault true;
        enableACME = lib.mkDefault true;

        locations."/" = {
          tryFiles = "$uri @proxy";
        };

        locations."@proxy" = {
          proxyPass = "http://127.0.0.1:${toStringport}";
          proxyWebsockets = true;
        };
        locations."/api/v1/streaming/" = {
          proxyPass = "http://127.0.0.1:${toString(port + 1)}/";
          proxyWebsockets = true;
        };
      };
    };

    services.elasticsearch = {
      enable = true;
      cluster_name = "mastodon-es";
      package = pkgs.elasticsearch7;
    };

    services.mastodon = {
      enable = true;
      webPort = port;
      # just take the next :shrug:
      streamingPort = port + 1;
      enableUnixSocket = false;
      localDomain = server_name;
      # todo: make a variable for this somewhere
      trustedProxy = networking.localIp;

      configureNginx = false;

      redis = { createLocally = true; };

      elasticsearch = {
        host = "127.0.0.1";
        inherit (config.services.elasticsearch) port;
      };

      database = {
        createLocally = false;
        user = database.username;
        passwordFile = pkgs.writeText "database-password" database.password;
        inherit (database) port;
        inherit (database) name;
        inherit (database) host;
      };

      smtp = {
        createLocally = false;
        fromAddress = "Mastodon <notifications@jdonszelmann.nl>";
        host = "smtp.mailgun.org";
        user = "${vs.mastodon}/smtp-username";
        authenticate = true;
        port = 587;
        passwordFile = "${vs.mastodon}/smtp-password";
      };

      extraConfig = {
        BIND = "0.0.0.0";
        SINGLE_USER_MODE = "true";
        DEFAULT_LOCALE = "en";

        WEB_DOMAIN = domain;

        SMTP_AUTH_METHOD = "plain";
        SMTP_OPENSSL_VERIFY_MODE = "none";

        RAILS_SERVE_STATIC_FILES = "true";
        AUTHORIZED_FETCH = "true";

        # https://github.com/cybrespace/cybrespace-meta/blob/master/s3.md;
        # https://shivering-isles.com/Mastodon-and-Amazon-S3
        S3_ENABLED = "true";
        S3_BUCKET = "mastodon";
        S3_PROTOCOL = "https";
        S3_HOSTNAME = "s3.donsz.nl";
        S3_ENDPOINT = "https://s3.donsz.nl";

        AWS_ACCESS_KEY_ID = "${vs.mastodon}/s3-access";
        AWS_SECRET_ACCESS_KEY = "${vs.mastodon}/s3-secret";

        DEEPL_PLAN = "free";

        ES_ENABLED = "true";
      };
    };

    # https://github.com/NixOS/nixpkgs/issues/116418#issuecomment-799517120
    systemd.services.mastodon-media-prune =
      let cfg = config.services.mastodon;
      in
      {
        description = "Mastodon media prune";
        environment = lib.filterAttrs (n: _: n != "PATH")
          config.systemd.services.mastodon-web.environment;
        serviceConfig = {
          Type = "oneshot";
          # Remove remote media attachments older than one month.
          ExecStart = "${cfg.package}/bin/tootctl media remove --days=30";
          User = cfg.user;
          Group = cfg.group;
          # TODO: vault?
          EnvironmentFile = "/var/lib/mastodon/.secrets_env";
          PrivateTmp = true;
        };
      };

    systemd.timers.mastodon-media-prune = {
      description = "Mastodon media prune";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 00:00:00"; # every day
        Unit = "mastodon-media-prune.service";
        AccuracySec = "60s";
      };
    };

    networking.firewall =
      let cfg = config.services.mastodon;
      in { allowedTCPPorts = [ cfg.streamingPort cfg.webPort ]; };
  }
]

