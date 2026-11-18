{ config, ... }:

{
  barrybenson.services.bazarr.webui.port = config.nixarr.bazarr.port;

  nixarr.bazarr = {
    enable = true;
    # Sonarr/Radarr connections (API keys included), so bazarr sees the library.
    # NOTE: currently a no-op: it posts JSON but bazarr (1.6) only reads form data; set by hand for now
    # (see imperative_setup.md)
    settings-sync = {
      sonarr.enable = true;
      radarr.enable = true;
    };
  };

  aln.impermanence.dirs = [ config.nixarr.bazarr.stateDir ];
}
