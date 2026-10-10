{
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

  # Need network-online for podman-user-wait-network-online.service
  systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

  # Advertise barrybenson.local on the LAN (mDNS), so clients don't need its DHCP ip
  services.avahi = {
    enable = true;
    openFirewall = true; # udp 5353
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # # Firewall
  # networking.nftables.enable = true; # keep nftables backend for podman
  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [
  #     22 # ssh
  #   ];
  # };


  sops.templates."nm-secrets-env".content = ''
    PASSWD_HOME_UV=${config.sops.placeholder."passwd_home"}
  '';

  sops.secrets."passwd_home" = {
    sopsFile = alnLib.relToRoot "secrets/host/wifi_passwd.yaml";
    key = "home_uv";
  };
}
