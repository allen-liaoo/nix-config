{
  inputs,
  lib,
  ...
}:

let
  modulePath = [
    "programs"
    "glide-browser"
  ];
in
{
  imports = [
    inputs.glide.homeModules.default
    (import ./_firefox/mkModule { inherit modulePath; })
    (import ./_firefox/config {
      inherit modulePath;
      profile = "default";
    })
  ];

  programs.glide-browser = {
    enable = false;
    pywalfox.enable = false;
    # disable toolbar
    profiles.default.settings."browser.uiCustomization.state" = { };
  };
}
