{ config, lib, ... }:
with lib;
let
  customUser = { name, config, ... }:
    {
      options = {
        minecraft = mkOption {
          type = with types; submodule {
            options = {
              username = mkOption {
                type = string;
              };
              uuid = mkOption {
                type = string;
              };
            };
          };
          example = {
            username = "jonay2000";
            uuid = "ae528e39-5a10-40f7-84e9-9d15ddaf7c7d";
          };
          description = "information about a user's minecraft information";
        };
      };
    };
in
{
  options = {
    users.users = mkOption {
      type = types.attrsOf (types.submodule customUser);
    };
  };
}
