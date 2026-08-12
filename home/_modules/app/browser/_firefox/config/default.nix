{ modulePath, profile }@args:

{
  lib,
  pkgs-nur,
  ...
}:

{
  imports = [
    (import ./policies.nix args)
    (import ./search.nix args)
    (import ./settings.nix args)
    (import ./toolbar.nix args)
  ];
}
// lib.setAttrByPath modulePath {
  languagePacks = [ "en-US" ];

  profiles.${profile} = {
    settings = {
      "extensions.autoDisableScopes" = 0; # auto enable 3rd party extensions
    };

    wavefox = {
      config = {
        "HorizontalTabs.AttachedTabs" = "true";
        "HorizontalTabs.AttachedTabs.Shape" = 1;
        "HorizontalTabs.AttachedTabs.Shape.Mode" = 1;
        "HorizontalTabs.Toolbar.Roundings" = 4;
        "HozitontalTabs.AttachedTabs.Separators" = 1;
      };
    };

    extensions.packages = with pkgs-nur.repos.rycee.firefox-addons; [
      bitwarden
      # TODO: gitflic.ru 404 error
      # bypass-paywalls-clean
      darkreader
      ublock-origin-upstream
      vimium
    ];
  };
}
