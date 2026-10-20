{ inputs, config, lib, ... }:

# Media stack, managed by nixarr: it creates the users (static uids), the "media" group,
# state dirs, media dirs and API key plumbing between services
{
  imports = [ inputs.nixarr.nixosModules.default ];

  options.barrybenson.services = lib.mkOption {
    type = with lib.types; attrsOf (submodule ({ lib, name, ... }: {
      options.webui = {
        enable = lib.mkEnableOption "webui";
        subdomain = lib.mkOption {
          type = lib.types.str;
          default = name;
        };
        port =  lib.mkOption {
          type = lib.types.int;
        };
      };
      config.webui.enable = lib.mkDefault true;
    }));
  };

  config = {
    nixarr = {
      enable = true;
      # @media subvolume (see disko.nix)
      # downloads (qbittorrent/) and library (library/) on the same fs so *arr hardlinks instead of copying
      mediaDir = "/srv/media";
      stateDir = "/var/lib/nixarr";
    };

    # nixarr's tmpfiles set the owner/mode of each service's state dir inside
    aln.impermanence.dirs = [ config.nixarr.mediaDir config.nixarr.stateDir ];
  };
}
