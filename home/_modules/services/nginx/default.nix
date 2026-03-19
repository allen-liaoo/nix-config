{ config, pkgs, aln, ... }:

let
  name = "nginx";
  cert_dir = "/var/tmp/cert";
in
{
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) images;
  in {
    containers.${name} = aln.lib.mkContainer name {
      containerConfig = {
        image = images.${name}.ref;
        exec = "nginx -g \"daemon off\";";
  
        publishPorts = [ "8080:8080" "8443:8443" ];
        userns = "host";
        volumes = [
          ("" + ./nginx.conf + ":/etc/nginx/nginx.conf:ro")
          ("" + ./sites + ":/etc/nginx/sites:ro")
          ("" + ./snippets + ":/etc/nginx/snippets:ro")
          ("${cert_dir}:/etc/letsencrypt:ro")
          "nginx_logs:/var/logs/nginx:rw"
        ];
  
        healthCmd = "service nginx status || exit 1";
        healthInterval = "1m";
        healthStartPeriod = "1m";
      };
    };

    images.${name} = aln.lib.mkImage name {
      imageConfig.image = "docker.io/library/nginx";
    };
  };

  # systemd service and timer to reload ssl cert
  systemd.user.services."${name}_reload_cert" = {
    Unit = {
      Description = "Reload nginx ssl certificate";
      After = "network-online.target";
      Wants = "network-online.target";
    };

    Service = {
      Type = "oneshot";
      ExecStart = let 
        domain = "allenl.me";
        email = "wcliaw610@gmail.com";
        secret_path = config.sops.secrets.nginx_cert_cloudflare.path;
      in pkgs.writeShellScript "obtain_cert" ''
        #!/bin/bash

        CERTBOT_LETSENCRYPT="${cert_dir}/data/cert/letsencrypt"
        CERTBOT_LIVE="$CERTBOT_LETSENCRYPT/live/$DOMAIN"

        ${pkgs.coreutils}/bin/mkdir -p "$CERTBOT_LETSENCRYPT"

        echo "Requesting wildcard certificate from Let's Encrypt..."
        ${pkgs.podman}/bin/podman run --rm \
            -v "$CERTBOT_LETSENCRYPT:/etc/letsencrypt:rw" \
            -v "${secret_path}:/etc/cloudflare_secret:ro" \
            docker.io/certbot/dns-cloudflare certonly \
                --dns-cloudflare \
                --dns-cloudflare-credentials /etc/cloudflare_secret \
                -d "${domain}" \
                -d "*.${domain}" \
                --email "${email}" \
                --agree-tos \
                --no-eff-email \
                --non-interactive \
                --force-renewal
      '';
      ExecStartPost = "systemctl --user restart ${name}.service";
    };
  };
}
