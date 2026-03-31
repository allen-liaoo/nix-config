{ lib, pkgs-nur, ... }:

let 
  extensions = import ./extensions_meta.nix;
in
{
  programs.firefox = {
    profiles.default.extensions.force = true;

    # installs extensions from the mozilla store
    policies.ExtensionSettings = lib.mergeAttrsList (map (ext: lib.optionalAttrs (ext ? name && ext.name != "") {
      ${ext.id} = {
        install_url       = "https://addons.mozilla.org/firefox/downloads/latest/${ext.name}/latest.xpi";
        installation_mode = "force_installed";
        updates_disabled  = true;
      };
    }) extensions);

    # set extension settings
    profiles.default.extensions.settings = lib.mergeAttrsList (map (ext: lib.optionalAttrs (ext ? settings && ext.settings != { }) {
      ${ext.id} = ext.settings;
    }) extensions);

    # 3rd party extensions
    profiles.default.extensions.packages = with pkgs-nur.repos.rycee.firefox-addons; [
      bypass-paywalls-clean
    ];
    profiles.default.settings = {
      "extensions.autoDisableScopes" = 0; # auto enable 3rd party extensions
    };
  };
}
