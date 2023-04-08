# Heavily inspired by https://github.com/NULLx76/infrastructure

{
  description = "Jonathan Dönszelmann's infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    colmena.url = "github:zhaofengli/colmena";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nixvim.url = "github:pta2002/nixvim";
  };

  outputs = { nixpkgs, colmena, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ];
      };
      util = import ./util/default.nix inputs;
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
    };
}
