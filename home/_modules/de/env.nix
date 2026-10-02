{
  lib,
  config,
  ...
}:

lib.mkIf config.aln.de.enable {
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_QPA_PLATFORMTHEME_QT6 = "gtk3";

    # Qt's gtk3 theme plugin and native GTK apps (Firefox, etc.) both implement
    # "native" file dialogs via GtkFileChooserNative, which only goes through
    # xdg-desktop-portal when this is set
    GTK_USE_PORTAL = "1";

    # required by electron
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
}
