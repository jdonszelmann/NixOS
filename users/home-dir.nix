{ lib, ... }:
with lib;
let
  for-host = { name, config, ... }: { };
  home-dir = { name, config, ... }:
    {
      options = {
        home-dir = mkOption {
          type = types.attrsOf (types.submodule for-host);
        };
      };
    };
in
{
  options = {
    home-dirs = mkOption {
      type = types.attrsOf (types.submodule home-dir);
    };
  };
}
