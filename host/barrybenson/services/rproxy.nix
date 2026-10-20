{
  config,
  lib,
  pkgs,
  ...
}:

# Reverse proxy for LAN clients: http://<service>.<hostname>.local -> service on localhost
# Names are resolved via mDNS: avahi publishes the hostname itself, and we publish an extra
# address record per service (avahi-alias-<service>)
let
  services = lib.pipe config.barrybenson.services [
    (lib.mapAttrs (_:v: v.webui))
    (lib.filterAttrs (_:v: v.enable))
  ];
  domain = "${config.networking.hostName}.local";
  fallback = "jellyfin"; # served on bare ip, for clients without mDNS (i.e. smart TVs)
in
{
  services.caddy = {
    enable = true;
    # Common settings shared by all virtual hosts
    extraConfig = ''
      (common) {
        encode zstd gzip
        header {
          X-Frame-Options "SAMEORIGIN"
          Referrer-Policy "strict-origin-when-cross-origin"
          -Server
        }
      }
    '';
    virtualHosts =
      lib.mapAttrs' (
        name: conf:
        lib.nameValuePair "http://${conf.subdomain}.${domain}" {
          extraConfig = ''
            import common
            reverse_proxy 127.0.0.1:${toString conf.port}
          '';
        }
      ) services
      // lib.optionalAttrs (services ? ${fallback}) {
        # any host not matched above (i.e. http://<ip>)
        ":80".extraConfig = ''
          import common
          reverse_proxy 127.0.0.1:${toString services.${fallback}.port}
        '';
      };
  };
  networking.firewall.allowedTCPPorts = [ 80 ];

  systemd.services = {
    caddy = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };
  }
  # Publish <service>.<hostname>.local
  // lib.mapAttrs' (
    _: v:
    lib.nameValuePair "avahi-alias-${v.subdomain}" {
      description = "Publish ${v.subdomain}.${domain} via mDNS";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "avahi-daemon.service"
      ];
      requires = [ "avahi-daemon.service" ];
      path = with pkgs; [
        iproute2
        gnused
        avahi
      ];
      # source ip of the default route = LAN ip, whatever the interface
      script = ''
        ip=$(ip -4 route get 1.1.1.1 | sed -n 's/.* src \([0-9.]*\).*/\1/p')
        [ -n "$ip" ] || { echo "no LAN ip yet"; exit 1; }
        exec avahi-publish --address --no-reverse "${v.subdomain}.${domain}" "$ip"
      '';
      serviceConfig = {
        Restart = "always";
        RestartSec = 5;
      };
    }
  ) services;

  aln.impermanence.dirs = [ config.services.caddy.dataDir ]; # StateDirectory=, systemd sets the owner
}
