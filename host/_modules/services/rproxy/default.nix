{ lib, config, pkgs, aln, ... }:

let
  name = "rproxy";
  dataVolumeName = name + "_data";
  blogGitUrl = "https://github.com/allen-liaoo/alsblog.git";
  blogCache = "/tmp/alsblog";
  domain = "allenl.me";
  cloudflare_secret_key = "cloudflare_token";
  cloudflare_secret_name = "rproxy_" + cloudflare_secret_key;
in
{
  virtualisation.quadlet = let
    inherit (config.virtualisation.quadlet) images volumes;
  in {
    containers.${name} = aln.lib.mkContainer name {
      containerConfig = {
        image = images.${name}.ref;
        # exec = "caddy run --config /etc/caddy/Caddyfile";
  
        publishPorts = [ "80:80" "443:443" ];
        userns = "auto";
        volumes = [
          "${./conf}:/etc/caddy:ro"
          "${blogCache}/build:/srv/alsblog:ro"
          "${volumes.${dataVolumeName}.ref}:/data:rw"
        ];

        environments = {
          DOMAIN = domain;
        };
        # secret passed in as environment variable for caddy dns provider
        environmentFiles = [ config.sops.templates.${cloudflare_secret_name}.path ];
      };
      serviceConfig = {
        # Check if blog files exists, if not, build it
        ExecStartPre = let
          buildBlog = pkgs.writeShellApplication {
            name = "build-alsblog";
            runtimeInputs = [ pkgs.git pkgs.hugo ];
            text = ''
              blog_build="${blogCache}/build"
              blog_build_tmp="${blogCache}/build.tmp"
              blog_repo="${blogCache}/repository"
              
              # Ensure cache directory exists
              mkdir -p "${blogCache}"

              # Keep repository and submodules up to date.
              if [ ! -d "$blog_repo/.git" ]; then
                git clone --recurse-submodules ${blogGitUrl} "$blog_repo"
              else
                git -C "$blog_repo" pull --ff-only
                git -C "$blog_repo" submodule update --init --recursive
              fi

              rm -rf "$blog_build_tmp"
              hugo --source="$blog_repo" --destination="$blog_build_tmp" --gc
              rm -rf "$blog_build"
              mv "$blog_build_tmp" "$blog_build"
            '';
          };
        in "${buildBlog}/bin/${buildBlog.name}";
      };
    };

    images.${name} = aln.lib.mkImage name {
      imageConfig.image = "ghcr.io/caddy-dns/cloudflare";
    };

    volumes.${dataVolumeName} = aln.lib.mkVolume dataVolumeName {};
  };

  sops.secrets.${cloudflare_secret_name} = {
    sopsFile = aln.lib.relToRoot "secrets/services/rproxy.yaml";
    key = cloudflare_secret_key;
  };

  # build environment file for secret
  sops.templates.${cloudflare_secret_name}.content = "CF_API_TOKEN=${config.sops.placeholder.${cloudflare_secret_name}}";
}