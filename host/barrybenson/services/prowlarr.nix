{
  config,
  ...
}:

{
  barrybenson.services.prowlarr.webui.port = config.nixarr.prowlarr.port;
  nixarr.prowlarr = {
    enable = true;
    settings-sync = {
      # Automatically sync all enabled Nixarr apps to Prowlarr.
      enable-nixarr-apps = true;
      indexers = [
        # { sort_name = "1337x"; } # blocked by cloudflare
        { sort_name = "anime tosho"; }
        { sort_name = "knaben"; }
        { sort_name = "limetorrents"; }
        { sort_name = "nyaa si"; }
        { sort_name = "magnet cat"; }
        { sort_name = "pirate bay"; }
        { sort_name = "torrentdownload"; }
        { sort_name = "torrent downloads"; }
        { sort_name = "yts"; }
      ];
    };
  };

  services.prowlarr.settings.auth.required = "DisabledForLocalAddresses";

  aln.impermanence.dirs = [ config.nixarr.prowlarr.stateDir ];
}

# sudo nixarr show-prowlarr-schemas indexer  | jq -r '.[] | select(.privacy == "public" and .protocol == "torrent") | [.sort_name, .description] | @tsv'
