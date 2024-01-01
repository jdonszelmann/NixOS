{ lib, config, pkgs, inputs, util, ... }:
let
  root = "${config.fileSystems.nas.mountPoint}/syncthing";
  inherit (config.services.syncthing) devices;

  status-domain = "relay-status.donsz.nl";
  status-port = util.randomPort status-domain;
  status-proxy = util.reverse-proxy {
    from = status-domain;
    to = status-port;
  };
in
status-proxy.create // {
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
          statusPort = status-port;
        };

      devices = {
        # lenovo ideapad laptop
        "ori" = {
          id = "HOZZUCT-32ZKOC2-SFTZMXC-YMWNP2S-HKR4CSU-3JEI5TC-IMW5SU2-U7HSFAI";
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

