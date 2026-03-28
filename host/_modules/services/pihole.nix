{ lib, config, pkgs, aln, ... }:

let
  name = "pihole";
  dataVolumeName = name + "_data";
in
{
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) images volumes;
  in {
    images.${name} = aln.lib.mkImage name {
      imageConfig.image = "docker.io/pihole/pihole:latest";
    };
    containers.${name} = aln.lib.mkContainer name {
      containerConfig = {
        image = images.${name}.ref;
        publishPorts = [ "53:53" "53:53/udp" "30080:80" ];
        userns = "auto";
        volumes = [
          "${volumes.${dataVolumeName}.ref}:/data:rw"
        ];
        environments = {
          FTLCONF_webserver_api_password = ""; # disable password
          FTLCONF_webserver_port = "80,[::]:80";
          FTLCONF_dns_listeningMode = "single";
          # google and cloudflare dns
          FTLCONF_dns_upstreams = "8.8.8.8;8.8.4.4;2001:4860:4860:0:0:0:0:8888;2001:4860:4860:0:0:0:0:8844;1.1.1.1;1.0.0.1;2606:4700:4700::1111;2606:4700:4700::1001";
          FTLCONF_dns_dnssec = "true";
          # Set allenl.me and its subdomains to use vps's vpn ip
          # Pihole itself doesn't support wildcard domain mapping, so we use dnsmasq config instead
          FTLCONF_misc_dnsmasq_lines = "address=/allenl.me/10.0.0.1";
          FLCONF_misc_privacylevel = "2"; # hide domain and clients in query logs 
          PH_VERBOSE = "1";
          FTLCONF_debug_webserver = "true";
        };
      };
    };
    volumes.${dataVolumeName} = aln.lib.mkVolume dataVolumeName {};
  };

  # Disable local DNS stub listener on 127.0.0.53
  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';
}
