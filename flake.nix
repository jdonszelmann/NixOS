# Heavily inspired by https://github.com/NULLx76/infrastructure (thank you <3)

{
  description = "Jonathan Dönszelmann's infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vault-secrets.url = "github:serokell/vault-secrets";
    ifsc-proxy.url = "github:jdonszelmann/ifsc-proxy";
    vault-unseal.url = "git+https://git.0x76.dev/v/vault-unseal.git";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    comma.url = "github:nix-community/comma";
  };

  outputs = { nixpkgs, vault-secrets, self, microvm, home-manager, deploy-rs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      # pkgs = nixpkgs.legacyPackages.${system};
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
      nixosConfigurations.fili = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs =
          { inherit pkgs inputs; };
        modules = [
          ./hosts/fili/configuration.nix
        ];
      };
      deploy.nodes.fili = {
        hostname = "donsz.nl";
        fastConnection = true;
        profiles = {
          system = {
            sshUser = "jonathan";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.fili;
            user = "root";
          };
        };
      };
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

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
          deploy-rs.packages.${system}.deploy-rs
          # vault
          # (vault-push-approle-envs self { })
          # (vault-push-approles self { })
          nixUnstable
          fast-repl
        ];
      };
    };
}
