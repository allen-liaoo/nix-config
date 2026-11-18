{ config, ... }:

# Syncs TRaSH Guides quality profiles/custom formats into Sonarr/Radarr (daily, recyclarr.timer).
# Profiles are guide-backed (`trash_id`): their default custom format groups are synced too,
# see https://github.com/recyclarr/config-templates for what each template enables
{
  nixarr.recyclarr = {
    enable = true;
    configuration = {
      sonarr.series = {
        base_url = "http://127.0.0.1:${toString config.nixarr.sonarr.port}";
        api_key = "!env_var SONARR_API_KEY";
        quality_definition.type = "series";
        quality_profiles = [
          {
            trash_id = "72dae194fc92bf828f32cde7744e51a1"; # WEB-1080p
            reset_unmatched_scores.enabled = true;
          }
        ];
      };
      radarr.movies = {
        base_url = "http://127.0.0.1:${toString config.nixarr.radarr.port}";
        api_key = "!env_var RADARR_API_KEY";
        quality_definition.type = "movie";
        quality_profiles = [
          {
            trash_id = "d1d67249d3890e49bc12e275d989a7e9"; # HD Bluray + WEB
            reset_unmatched_scores.enabled = true;
          }
        ];
      };
    };
  };

  # guide/template git caches; re-cloned if missing, but keeps a cold boot from refetching
  aln.impermanence.dirs = [ config.nixarr.recyclarr.stateDir ];
}
