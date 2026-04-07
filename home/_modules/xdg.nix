{ lib, pkgs, config, aln, ... }:

{
  xdg = {
    enable = true;
    cacheHome  = config.home.homeDirectory + "/.cache";
    configHome = config.home.homeDirectory + "/.config";
    dataHome   = config.home.homeDirectory + "/.local/share";
    stateHome  = config.home.homeDirectory + "/.local/state";

  } // lib.optionalAttrs aln.ctx.host.is.gui {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "application/pdf" = "sioyek.desktop";
        "x-scheme-handler/discord" = "vesktop.desktop";
      };
    };

    portal =  {
      enable = true;
      config.common = {
        default = [ "gnome" ];
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
#        gnome-keyring
      ];
      xdgOpenUsePortal = true;
    };
  } // lib.optionalAttrs (!aln.ctx.host.is.server) {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
