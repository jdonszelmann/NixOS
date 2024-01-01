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

    ifsc-proxy.url = "github:jdonszelmann/ifsc-proxy";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    sops-nix.url = "github:jdonszelmann/sops-nix";

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    comma.url = "github:nix-community/comma";
  };

  outputs = { nixpkgs, self, microvm, home-manager, deploy-rs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      fast-repl = pkgs.writeShellScriptBin "fast-repl" ''
        source /etc/set-environment
        nix repl --file "${./.}/repl.nix" $@
      '';
    in
    {
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

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          deploy-rs.packages.${system}.deploy-rs
          nixUnstable
          fast-repl
        ];
      };
    };
}
