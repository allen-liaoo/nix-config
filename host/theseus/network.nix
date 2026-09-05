{
  lib,
  config,
  pkgs,
  alnLib,
  inventory,
  ctx,
  ...
}:

let
  # NM connections/profiles
  connections = [
    "hotspot_a16n"
  ];

  # whose ~/.joinnow eduroam certs (scripts/securew2-joinnow) wpa_supplicant needs to see;
  eduroamUser = inventory.users.allenl.name;
in
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
      # NOTE: trailing ":" is important in "list of ..." fields
      profiles = {
        # home server (DNS)
        wg_hs_dns =
          let
            ionobro = inventory.hosts.ionobro.data;
          in
          {
            connection = {
              id = "wg_hs_dns";
              type = "wireguard";
              interface-name = "wg_hs";
              autoconnect = false;
            };
            wireguard.private-key = "$WG_PRIVKEY";
            # TODO: Centralize keys and ips
            "wireguard-peer.${ionobro.wg_pubkey}" = {
              endpoint = "${ionobro.ip}:${ionobro.wg_port}";
              allowed-ips = "${ionobro.wg_ip}/24;";
              persistent-keepalive = 25;
            };
            ipv4 = with ctx.host.data; {
              address1 = "${wg_ip}/32";
              dns = "${ionobro.wg_ip};"; # trailing ";"!
              method = "manual";
            };
            ipv6.method = "disabled";
          };
        # phone
        a16n = {
          connection = {
            id = "a16n";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "a16n";
          };
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
        # OSU eduroam is intentionally NOT declared here: it's fully managed by
        # `scripts/securew2-joinnow` (see that directory's README), which talks
        # directly to NetworkManager over D-Bus to create/renew the connection.
      };
      # Fine to use env vars since the generated .nmconnection files are not in store
      environmentFiles = [ config.sops.templates."nm-secrets-env".path ];

      # NOTE: DO NOT RECOMMEND USING ensureProfiles.secrets (which uses nm-file-secret-agent)
      # as it is unreliable especially if nmcli is called with a different user than the one who runs the agent (root)
      # See: https://github.com/lilioid/nm-file-secret-agent/issues/4

      # To use it: set flags indicate field is agent owned (i.e. wifi-security.psk-flags = 1)
      # And it runs a systemd service "nm-file-secret-agent"
      # Note that in ensureProfiles.secrets, match names dont use aliases like above
    };
  };

  # wpa_supplicant.service runs with RootDirectory=/run/wpa_supplicant + ProtectHome=true,
  # so it can't see cert/key files under /home by default (fails with a misleading
  # "No such file or directory" from OpenSSL). eduroam's EAP-TLS cert/key (written by
  # scripts/securew2-joinnow into ~/.joinnow) need to be visible to it.
  #
  # ProtectHome=true mounts a shared, read-only, mode-000 placeholder over /home
  # (confirmed via /proc/<pid>/root/home). Because it's read-only, systemd can't
  # create the nested <user>/.joinnow directories needed to attach a BindReadOnlyPaths
  # mount underneath it - the bind silently never attaches, no matter how the host-side
  # directory chain is prepared. RootDirectory already isolates this unit from the real
  # filesystem almost entirely, so ProtectHome's extra masking of /home specifically is
  # redundant defense-in-depth here - turn off just that layer to unblock the bind.
  systemd.services.wpa_supplicant.serviceConfig = {
    ProtectHome = lib.mkForce false;
    ExecStartPre = [
      "+${pkgs.coreutils}/bin/mkdir -p /run/wpa_supplicant/home/${eduroamUser}/.joinnow"
      "+${pkgs.coreutils}/bin/chmod 755 /run/wpa_supplicant/home /run/wpa_supplicant/home/${eduroamUser} /run/wpa_supplicant/home/${eduroamUser}/.joinnow"
    ];
    BindReadOnlyPaths = [
      "/home/${eduroamUser}/.joinnow"
    ];
  };

  sops.secrets =
    (
      connections
      |> map (key: {
        "passwd_${key}" = {
          sopsFile = alnLib.relToRoot "secrets/host/wifi_passwd.yaml";
          inherit key;
        };
      })
      |> lib.mergeAttrsList
    )
    // {
      theseus_wg_privkey = {
        sopsFile = alnLib.relToRoot "secrets/host/theseus/common.yaml";
        key = "wg_privkey";
      };
    };

  sops.templates."nm-secrets-env".content =
    (
      connections
      |> map (key: "PASSWD_${lib.toUpper key}=${config.sops.placeholder."passwd_${key}"}")
      |> lib.concatMapStrings (s: s + "\n")
    )
    + ''
      WG_PRIVKEY=${config.sops.placeholder.theseus_wg_privkey}
    '';

}
