{ config, ... }:
let
  # host-data = import ./host-data.nix;
  host-data = config.custom.networking.host;
  vm-hosts = with builtins; attrNames host-data;
in
{
  networking.useNetworkd = true;
  systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # make the shared ssh directory on the host for each vm for
  # various purposes (currently only ssh)
  systemd.tmpfiles.rules = with builtins;
    concatLists (
      map
        (i: [
          "d /var/lib/microvms/${i}             0755 microvm -"
          "d /var/lib/microvms/${i}/storage     0755 microvm -"
          "d /var/lib/microvms/${i}/storage/etc 0755 microvm -"
        ])
        vm-hosts
    );

  systemd.network.enable = true;

  systemd.network = {
    # createa virtual network device called vmbridge
    netdevs."vmbridge" = {
      netdevConfig = {
        Name = "vmbridge";
        Kind = "bridge";
      };
    };

    # bind en* (my physical ethernet device, in this case
    # probably ens18) to this bridge. Now ens18 cannot 
    # have an ip address anymore. Instead, the bridge 
    # network gets one.
    #
    # Also bind every interface which starts with `vm-`.
    # that means *not* vmbridge (watch out, that'd break)
    # because you can't bind a bridge to a bridge. It does
    # mean that if we give all our vms an interface id of vm-*
    # they attach to this bridge!
    networks."10-uplink" = {
      matchConfig.Name = [ "en*" "vm-*" ];
      networkConfig = {
        Bridge = "vmbridge";
      };
    };

    # now we configure the bridge network
    networks."15-vmbridge" = {
      # it's associated with vmbridge
      matchConfig.Name = "vmbridge";
      networkConfig = {
        # get a DHCP lease (my router is set up
        # to always give me 192.168.0.59). To my initial
        # surprise, because of the bridge it seems
        # that my MAC address changed. The bridge network
        # seems to get its own so I had to change my router's
        # static lease setup to give the bridge IP address 59.
        DHCP = "yes";
        Address = [
          "10.0.0.1/24"
        ];

        # it's default gateway is 192.168.0.1, my external router
        Gateway = "192.168.0.1";
        # TODO: custom DNS
        DNS = [ "1.1.1.1" ];

        IPMasquerade = true;
        IPForward = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  networking.interfaces.vmbridge.ipv4.routes = [
    {
      address = "10.0.0.0";
      prefixLength = 24;
      via = "10.0.0.1";
    }
  ];
  systemd.services.network-addresses-vmbridge = {
    after = [ "systemd-networkd.service" ];
    wantedBy = [ "network-online.target" ];
  };
}

