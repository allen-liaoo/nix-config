{
  pkgs,
  config,
  alnLib,
  ...
}:

let
  ssid = "TP-Link_CF39";
  dns = "1.1.1.1;1.0.0.1;8.8.8.8;8.8.4.4;"; # trailing ";"!
in
{
  # NetworkManager (nmtui/nmcli) manages all interfaces
  networking.networkmanager = {
    ensureProfiles = {
      profiles.home_uv = {
        connection = {
          id = "home_uv";
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          inherit ssid;
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$PASSWD_HOME_UV";
        };
        ipv4 = {
          method = "auto";
          inherit dns;
          ignore-auto-dns = true; # use static DNS above
        };
        ipv6.method = "auto";
      };
      environmentFiles = [ config.sops.templates."nm-secrets-env".path ];
    };
  };

  # Services (caddy, mDNS aliases, qbittorrent) order after network-online
  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  # Advertise barrybenson.local on the LAN (mDNS), so clients don't need its DHCP ip
  services.avahi = {
    enable = true;
    openFirewall = true; # udp 5353
    publish = {
      enable = true;
      addresses = true;
      userServices = true; # allow publishing over D-Bus, needed by avahi-publish (services/rproxy.nix aliases)
    };
  };

  # Re-publish aliases when the ip may have changed (new DHCP lease, reconnect)
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "restart-avahi-aliases" ''
        case "$2" in
          up|dhcp4-change)
            ${config.systemd.package}/bin/systemctl try-restart 'avahi-alias-*.service' ;;
        esac
      '';
    }
  ];


  # Firewall: ssh (sshd.nix), mDNS (avahi) and http (services/rproxy.nix) open themselves;
  # services only listen behind the reverse proxy and don't open their own ports
  networking.firewall.enable = true;

  sops.templates."nm-secrets-env".content = ''
    PASSWD_HOME_UV=${config.sops.placeholder."passwd_home"}
  '';

  sops.secrets."passwd_home" = {
    sopsFile = alnLib.relToRoot "secrets/host/wifi_passwd.yaml";
    key = "home_uv";
  };
}
