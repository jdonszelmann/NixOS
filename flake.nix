# Heavily inspired by https://github.com/NULLx76/infrastructure

{
  description = "Jonathan Dönszelmann's infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    colmena.url = "github:zhaofengli/colmena";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    vault-secrets.url = "github:serokell/vault-secrets";
    # nixvim.url = "github:pta2002/nixvim";
  };

  outputs = { self, nixpkgs, colmena, vault-secrets, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ vault-secrets.overlay ];
      };
      util = import ./util/default.nix inputs;

      apply-local = pkgs.writeShellScriptBin "apply-local" ''
        "${
          colmena.packages.${system}.colmena
        }"/bin/colmena apply-local --sudo $@
      '';

      fast-repl = pkgs.writeShellScriptBin "fast-repl" ''
        source /etc/set-environment
        nix repl --file "${./.}/repl.nix" $@
      '';
    in
    {
      colmena = {
        meta = {
          nixpkgs = pkgs;
          specialArgs = { inherit util inputs; };
        };

        fili = {
          deployment = {
            targetHost = "donsz.nl";
            targetPort = 1234;
            targetUser = "system";
            tags = [ "fili" ];
          };

          imports = [ ./hosts/fili/configuration.nix ];
        };
      };

      packages.${system} = {
        default = colmena.packages.${system}.colmena;
      };

      devShells.${system}.default = pkgs.mkShell {
        VAULT_ADDR = "http://192.168.0.59:8200/";
        buildInputs = with pkgs; [
          apply-local
          colmena.packages.${system}.colmena
          cachix
          vault
          (vault-push-approle-envs self { })
          (vault-push-approles self { })
          fast-repl
        ];
      };
    };
}
