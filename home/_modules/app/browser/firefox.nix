{
  lib,
  pkgs,
  pkgs-unstable,
  config,
  ...
}:

let
  modulePath = [
    "programs"
    "firefox"
  ];
in
{
  imports = [
    (import ./firefox/mkModule { inherit modulePath; })
    (import ./firefox/config {
      inherit modulePath;
      profile = "default";
    })
  ];

  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox"; # new in 26.05
    pywalfox = {
      enable = true;
      package = pkgs-unstable.pywalfox-native;
    };
    profiles.default = {
      wavefox = {
        enable = true;
      };
    };
  };

  programs.dank-material-shell.settings = {
    matugenTemplateFirefox = true;
    matugenTemplatePywalfox = true;
  };

  # setup DMS managed matugen theme
  home.file.".cache/wal/colors.json".source = config.lib.file.mkOutOfStoreSymlink (
    config.home.homeDirectory + "/.cache/wal/dank-pywalfox.json"
  );
}
