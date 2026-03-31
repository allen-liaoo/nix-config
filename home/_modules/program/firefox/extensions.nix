{ lib, pkgs-nur, ... }:

let 
  # id is name@dev or {uuid}
  # name is name in mozilla store (if not 3rd party)
  extensions = [
    {
      id = "addon@darkreader.org";
      name = "darkreader";
    }
    {
      id = "uBlock0@raymondhill.net";
      name = "ublock-origin";
    }
    {
      id = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      name = "bitwarden-password-manager";
    }
  ];
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

# To find extension ids/uuids, go to about:debugging#/runtime/this-firefox
# To find extension name, check extension url in webstore, which should be something like
# https://addons.mozilla.org/en-US/firefox/addon/${name}/
