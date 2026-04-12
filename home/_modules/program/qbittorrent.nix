{
  pkgs,
  config,
  aln,
  ...
}:

{
  home.packages = with pkgs; [
    qbittorrent
  ];

  sops.secrets.jackett_api_key = {
    sopsFile = aln.lib.relToRoot "secrets/allenl/common.yaml";
    key = "jackett_api_key";
  };

  sops.templates.qbit_jackett_settings = ''
    {
      "api_key": "${config.sops.secrets.jackett_api_key}",
      "url": "https://jackett.allenl.me",
      "tracker_first": false,
      "thread_count": 20
    }
  '';
}
