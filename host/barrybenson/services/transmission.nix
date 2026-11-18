{ config, ... }:

# Downloads land in <mediaDir>/torrents/<category>; Sonarr/Radarr then import (hardlink, same fs) them
# into library/{shows,movies}, which jellyfin watches. Once imported and the torrent has stopped
# seeding, *arr removes the torrent from transmission (see `remove_completed_downloads` in sonarr/radarr.nix)
{
  barrybenson.services.transmission.webui.port = config.nixarr.transmission.uiPort;

  nixarr.transmission = {
    enable = true;
    flood.enable = true; # nicer webui, replaces the stock one
    extraSettings = {
      # Stop seeding at ratio 1, or after 30 min without uploading to anyone, whichever comes first.
      # *arr only removes a torrent once it has reached its seed limit and is stopped
      ratio-limit-enabled = true;
      ratio-limit = 1.0;
      idle-seeding-limit-enabled = true;
      idle-seeding-limit = 30; # minutes

      # caddy forwards the Host header; transmission rejects unknown non-IP hosts (421)
      rpc-host-whitelist-enabled = true;
      rpc-host-whitelist = "${config.barrybenson.services.transmission.webui.subdomain}.${config.networking.hostName}.local";

      # .torrent files dropped in torrents/.watch are deleted once added
      trash-original-torrent-files = true;
    };
  };

  aln.impermanence.dirs = [ config.nixarr.transmission.stateDir ];
}
