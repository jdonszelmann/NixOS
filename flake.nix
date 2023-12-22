# Heavily inspired by https://github.com/NULLx76/infrastructure (thank you <3)

{
  description = "Jonathan Dönszelmann's infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    colmena.url = "github:zhaofengli/colmena";
    home-manager.url = "github:nix-community/home-manager";

    vault-secrets.url = "github:serokell/vault-secrets";
    ifsc-proxy.url = "github:jdonszelmann/ifsc-proxy";
    vault-unseal.url = "git+https://git.0x76.dev/v/vault-unseal.git";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, vault-secrets, self, microvm, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # pkgs =
      # util = import ./util/default.nix inputs;
      # modules = import ./modules/default.nix inputs;

      #   apply-local = pkgs.writeShellScriptBin "apply-local" ''
      #     "${
      #       colmena.packages.${system}.colmena
      #     }"/bin/colmena apply-local --sudo $@
      #   '';

      #   apply-remote = pkgs.writeShellScriptBin "apply-remote" ''
      #     "${
      #       colmena.packages.${system}.colmena
      #     }"/bin/colmena apply --on "@fili"
      #   '';

        fast-repl = pkgs.writeShellScriptBin "fast-repl" ''
          source /etc/set-environment
          nix repl --file "${./.}/repl.nix" $@
        '';
    in
    {
      # necessary for vault to work
      nixosConfigurations =
        (import (inputs.colmena + "/src/nix/hive/eval.nix") {
          rawFlake = self;
          colmenaOptions =
            import (inputs.colmena + "/src/nix/hive/options.nix");
          colmenaModules =
            import (inputs.colmena + "/src/nix/hive/modules.nix");
        }).nodes;


      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            overlays = [
              vault-secrets.overlay
              inputs.nix-minecraft.overlay
            ];
            inherit system;
          };
        };

        fili = {
          deployment = {
            targetHost = "donsz.nl";
            targetUser = "jonathan";
            tags = [ "fili" ];
            allowLocalDeployment = true;
          };

          imports = [
            microvm.nixosModules.host
            inputs.nix-minecraft.nixosModules.minecraft-servers
            ./hosts/fili/configuration.nix
            # home-manager.nixosModules.home-manager
          ];
        };
      };

      # packages.${system} = {
      #   inherit apply-local;
      #   default = colmena.packages.${system}.colmena;

      #   push-vault-secrets = with pkgs;
      #     writeScriptBin "push-vault-secrets" ''
      #       set -o xtrace
      #       ${vault-push-approles self}/bin/vault-push-approles &&
      #         ${vault-push-approle-envs self}/bin/vault-push-approle-envs
      #     '';
      # };

      devShells.${system}.default = pkgs.mkShell {
        # VAULT_ADDR = "http://192.168.0.59:8200/";
        buildInputs = with pkgs; [
          # apply-local
          # apply-remote
          # colmena.packages.${system}.colmena
          # cachix
          # vault
          # (vault-push-approle-envs self { })
          # (vault-push-approles self { })
          nixUnstable
          fast-repl
        ];
      };
    };
}
