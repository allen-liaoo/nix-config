{ config, aln, ... }:

{
  networking.networkmanager = {
    logLevel = "INFO";
    ensureProfiles = {
      # Below profiles are generated as .nmconnection files in /run/NetworkManager/system-connections (or /etc/NetworkManager/system-connections?)
      # Reference: https://networkmanager.dev/docs/api/latest/nm-settings-keyfile.html
      # NM setting reference: https://networkmanager.dev/docs/api/latest/nm-settings-nmcli.html
      # Note that .nmconnection files, and hence below attrSets, should use aliases:
      # 802-3-ethernet = ethernet
      # 802-11-wireless = wifi
      # 802-11-wireless-security = wifi-security
      # (nm setting key = .nmconnection key)
      profiles = {
        # phone
        a16n = {
          connection = {
            id = "a16n";
            type = "wifi";
          };
          wifi.ssid = "a16n";
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$PASSWD_HOTSPOT_A16N";
          };
          ipv4.method = "auto";
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
        };
        # TODO: school (always auth timeout)
        # eduroam = {
        #   connection = {
        #     id = "eduroam";
        #     type = "wifi";
        #   };
        #   wifi = {
        #     ssid = "eduroam";
        #   };
        # };
      };
      # Fine to use env vars since the generated .nmconnection files are not in store
      environmentFiles = [ config.sops.templates."nm-secrets-env".path ];

      # NOTE: DO NOT RECOMMEND USING ensureProfiles.secrets (which uses nm-file-secret-agent)
      # as it is unreliable especially if nmcli is called with a different user than the one who runs the agent (root)
      # To use it: set flags indicate field is agent owned (i.e. wifi-security.psk-flags = 1)
      # And it runs a systemd service "nm-file-secret-agent"
      # Note that in ensureProfiles.secrets, match names dont use aliases like above
    };
  };

  sops.secrets = {
    passwd_hotspot_a16n = {
      sopsFile = aln.lib.relToRoot "secrets/host/wifi_passwd.yaml";
      key = "hotspot_a16n";
    };
  };

  sops.templates."nm-secrets-env".content = ''
    PASSWD_HOTSPOT_A16N=${config.sops.placeholder.passwd_hotspot_a16n}
  '';
}
