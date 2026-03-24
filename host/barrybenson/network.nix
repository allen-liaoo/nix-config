{ lib, config, pkgs, ... }:

let
  eth_intf = "enp1s0";
  wg_intf = "wg_vps";
  wg_mark = "51820";
in
{
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    wait-online.enable = true;
    networks."10-${eth_intf}" = {
      matchConfig.Name = "${eth_intf}";
      DHCP = "ipv4";
      linkConfig.RequiredForOnline = "routable";
      dns = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
    };
  };

  # Need network-online for podman-user-wait-network-online.service
  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  # firewall
  networking.firewall.enable = false; # use our own fw
  networking.nftables = {
    enable = true;
    checkRuleset = true;
    #flushRuleset = true; # do not flush, or podman's fw get flushed
    tables = {
      global = {
        family = "inet";
        content = ''
          set WG_SUBNETS { # trusted ips
              type ipv4_addr
              flags interval;
              elements = { 10.0.0.0/24, 10.0.10.0/24 }
          }
          chain input {
            type filter hook input priority 0; policy drop;
            ct state { established, related } accept
            iif "lo" accept
            ip protocol icmp limit rate 10/second accept
            ip6 nexthdr icmpv6 limit rate 10/second accept

            tcp dport 22 accept # ssh

            iifname "${wg_intf}" ip saddr @WG_SUBNETS accept
          }
          chain forward {
            type filter hook forward priority 0; policy drop;
          }
          chain output {
            type filter hook output priority 0; policy accept;
          }
        '';
      };
      internal_redirect = {
        family = "inet";
        content = ''
          chain prerouting {
            type nat hook prerouting priority -100; policy accept;
            tcp dport 80 counter dnat to :8080
            tcp dport 443 counter dnat to :8443
          };
        '';
      };
    };
  };

  # wireguard tunnel to vps
  systemd.network.networks."20-${wg_intf}" = {
    matchConfig.Name = "${wg_intf}";
    address = [ "10.0.0.2/24" ]; # this server's wg ip
    #routingPolicyRules = [{
      #FirewallMark = ${wg_mark};
      #Table = ${wg_mark};
      #Priority = 100;
    #}];
    #routes = [{
      #Destination = "0.0.0.0/0";
      #Table = ${wg_mark};
    #}];
  };

  systemd.network.netdevs."20-${wg_intf}" = {
    netdevConfig = {
      Name = wg_intf;
      Kind = "wireguard";
    };
    wireguardConfig = {
      PrivateKeyFile = config.sops.secrets.wg_privkey.path;
    };
    wireguardPeers = [{
      PublicKey = "CQvf4nOExaVkaiWpsxx0OctRU4N51xRYdKUoKteegQk=";
      Endpoint = "74.208.158.11:${wg_mark}";
      AllowedIPs = [ "10.0.0.1/32" ];
      PersistentKeepalive = 25;
    }];
  };

  environment.systemPackages = with pkgs; [ wireguard-tools ];

  sops.secrets.wg_privkey = {
    key = "wg_privkey";
    group = "systemd-network"; # ensure privkey readable by systemd-network
    mode = "0440";
  };
}
