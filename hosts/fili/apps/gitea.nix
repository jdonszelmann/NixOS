{ util, lib, config, ... }:
let
  vs = config.vault-secrets.secrets;
  domain = "git.donsz.nl";
  port = util.randomPort domain;
  reverse-proxy = util.reverse-proxy {
    from = domain;
    to = port;
  };
  database = util.database {

    type = "mysql";
  };
in
lib.mkMerge [
  reverse-proxy.create
  database.create
  {
    vault-secrets.secrets.gitea = { };

    # services.gitea = {
    #   enable = true;
    #   domain = "git.donsz.nl";
    #   rootUrl = "https://git.donsz.nl";
    #   lfs.enable = true;
    #   dump.type = "tar.gz";
    #   database = {
    #     type = database.type;
    #     port = database.port;
    #     password = database.password;
    #     name = database.name;
    #     host = database.host;
    #     user = database.username;
    #   };
    #   mailerPasswordFile = "${vs.gitea}/mailPassword";

    #   settings = {
    #     repository = {
    #       "ENABLE_PUSH_CREATE_USER" = true;
    #       "DEFAULT_PUSH_CREATE_PRIVATE" = false;
    #     };
    #     service = {
    #       "DEFAULT_KEEP_EMAIL_PRIVATE" = true;
    #       "DISABLE_REGISTRATION" = true;
    #     };
    #     indexer = {
    #       "REPO_INDEXER_ENABLED" = true;
    #       "REPO_INDEXER_PATH" = "indexers/repos.bleve";
    #       "UPDATE_BUFFER_LEN" = 20;
    #       "MAX_FILE_SIZE" = 1048576;
    #       "REPO_INDEXER_EXCLUDE" = "node_modules/**";
    #     };
    #     ui = {
    #       "THEMES" = "gitea,arc-green";
    #       "DEFAULT_THEME" = "gitea";
    #       "USE_SERVICE_WORKER" = true;
    #     };
    #     server = {
    #       "LANDING_PAGE" = "explore";
    #       "SSH_PORT" = 2222;
    #     };
    #     session = {
    #       "PROVIDER" = "db";
    #       "COOKIE_SECURE" = true;
    #     };
    #     mailer = {
    #       "ENABLED" = true;
    #       "IS_TLS_ENABLED" = true;
    #       "HOST" = "${vs.gitea}/smtp-username";
    #       "FROM" = "Gitea <notifications@jdonszelmann.nl>";
    #       "MAILER_TYPE" = "smtp";
    #       "USER" = "${vs.mastodon}/smtp-username";
    #     };
    #   };
    # };
  }
]
