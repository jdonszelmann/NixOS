# Heavily inspired by https://github.com/NULLx76/infrastructure (thank you <3)

{
  description = "Jonathan Dönszelmann's infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";

    master.url = "github:NixOS/nixpkgs/master";

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

    statix.url = "github:nerdypepper/statix";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { nixpkgs, self, microvm, home-manager, deploy-rs, statix, master
    , ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ (import ./pkgs) inputs.nix-minecraft.overlay ];
      };
      fast-repl = pkgs.writeShellScriptBin "fast-repl" ''
        source /etc/set-environment
        nix repl --file "${./.}/repl.nix" $@
      '';
    in {
      nixosConfigurations.fili = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs inputs master; };
        modules = [ ./hosts/fili/configuration.nix ];
      };

      nixosConfigurations.ori = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs inputs master; };
        modules = [ ./hosts/ori/configuration.nix ];
      };

      deploy.nodes.fili = {
        # hostname = "donsz.nl";
        hostname = "192.168.178.59";
        fastConnection = true;
        profiles = {
          system = {
            sshUser = "jonathan";
            path = deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.fili;
            user = "root";
          };
        };
      };
      deploy.nodes.ori = {
        hostname = "ori";
        fastConnection = true;
        profiles = {
          system = {
            sshUser = "jonathan";
            path = deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.ori;
            user = "root";
          };
        };
        remoteBuild = true;
      };

      gtnh-server = pkgs.custom.gtnh-server;

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          deploy-rs.packages.${system}.deploy-rs
          statix.packages.${system}.statix
          nixUnstable
          fast-repl
        ];
        shellHook = "exec $NIX_BUILD_SHELL";
      };
    };
}
