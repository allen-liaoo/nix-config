{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf config.aln.app.enable {
  programs.sioyek = {
    enable = true;
    # sioyek's open-file dialog is Qt's native QFileDialog, which inherits the
    # global QT_QPA_PLATFORMTHEME=gtk3 (set in de/env.nix) and so bypasses
    # xdg-desktop-portal entirely, going straight to GTK/nautilus instead of
    # respecting our termfilechooser  FileChooser preference. Force
    # just this app through the portal so it picks up that preference.
    package = pkgs.sioyek.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postFixup = ''
        ${old.postFixup or ""}
        wrapProgram $out/bin/sioyek \
          --set QT_QPA_PLATFORMTHEME xdgdesktopportal \
          --set QT_QPA_PLATFORMTHEME_QT6 xdgdesktopportal
      '';
    });
    config = {
      should_launch_new_window = "1";
    };
    bindings = {
      "next_page" = "<C-d>";
      "previous_page" = "<C-u>";
      "fit_to_page_height" = "0";
      "goto_top_of_page" = "H";
      "goto_bottom_of_page" = "L";
    };
  };
}
