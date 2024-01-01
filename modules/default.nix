{ inputs, lib, config, ... }: {
  imports = [ ./matrix-registration ./ifsc-proxy ./dns.nix ];
}
