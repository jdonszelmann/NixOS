{ lib, config, pkgs, inputs, ... }:
let
  root = "/storage/storage/syncthing";
  inherit (config.services.syncthing) devices;

  proxy = config.custom.networking.proxy;
in
{
  services = {
    syncthing = {
      user = "jonathan";
      group = "syncthing";

      enable = true;
      dataDir = root;
      configDir = root;
      overrideDevices = true;
      overrideFolders = true;
      openDefaultPorts = true;

      relay =
        {
          enable = true;
          port = 22001;
          listenAddress = "0.0.0.0";
          providedBy = "Jonathan Dönszelmann";
          statusListenAddress = "0.0.0.0";
          statusPort = proxy."relay-status.donsz.nl".port;
        };

      devices = {
        # lenovo ideapad laptop
        "ori" = {
          id = "GQ3BEZA-NPJNM4J-ZEDGEHB-W6XEPQR-SSHEQDA-R6ODPPX-T5ZTO7J-FSCAEQE";
          introducer = true;
          autoAcceptFolders = true;
        };
        # HP tudelft project laptop
        "nori" = {
          id = "HKTBAV2-ADDOOIQ-VRFW7QZ-4I5EYYU-F5N3BX5-G3SVP3V-HAGCG6C-JPMHUAB";
          introducer = true;
          autoAcceptFolders = true;
        };
        "kili" = {
          id = "DRYPY6Q-SHIYZVD-J33UTDW-NWEQSVL-UHUXCVP-WPPADQP-XHRA3PQ-7FPA3AI";
          introducer = true;
          autoAcceptFolders = true;
        };
      };
      folders = {
        "projects" = {
          path = "${root}/projects";
          devices = [ "ori" "kili" ];
        };
        "study" = {
          path = "${root}/study";
          devices = [ "ori" ];
        };
        "work-tudelft" = {
          path = "${root}/work-tudelft";
          devices = [ "ori" "kili" ];
        };
        "torrents" = {
          path = "${root}/torrents";
          devices = [ "nori" ];
        };
        "books" = {
          path = "${root}/books";
          devices = [ "ori" ];
        };
        "pictures" = {
          path = "${root}/pictures";
          devices = [ "ori" "kili" ];
        };
      };
    };
  };
}

