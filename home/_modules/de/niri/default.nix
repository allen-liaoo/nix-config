{ lib, pkgs, config, aln, ... }:

let 
  symlinkTo = f: f |> aln.lib.outOfStoreRelToRoot config.home.homeDirectory |> config.lib.file.mkOutOfStoreSymlink;
  alacrittyKdl = pkgs.writeText "alacritty.kdl" ''
    binds {
      Mod+T hotkey-overlay-title="Open a Terminal" {
        spawn "${config.programs.alacritty.package}/bin/alacritty";
      }
    }
    window-rule { // Open terminal in single column
      match app-id=r#"Alacritty"#
      open-maximized false
      open-maximized-to-edges false
    }
  '';
  fcitx5Kdl = pkgs.writeText "fcitx5.kdl" ''
    binds {
      Mod+Space hotkey-overlay-title="Switch input method" {
        spawn "${config.i18n.inputMethod.fcitx5.fcitx5-with-addons}/bin/fcitx5-remote" "-t";
      }
    }
  '';
in
{
  xdg.configFile."niri/config.kdl".text = ''
    include "${symlinkTo ./general.kdl}"
    include "${symlinkTo ./binds.kdl}"
     
    ${lib.optionalString (config.programs.dank-material-shell.enable) ''
    include "${symlinkTo ./dms.kdl}"
    include "dms/alttab.kdl"
    include "dms/outputs.kdl" // displays
    include "dms/wpblur.kdl"  // blurring wallpaper settings
    ''}

    ${lib.optionalString (config.services.vicinae.enable) ''
    include "${symlinkTo ./vicinae.kdl}"
    ''}

    ${lib.optionalString (config.programs.alacritty.enable) ''
    include "${alacrittyKdl}"
    ''}

    ${with config.i18n.inputMethod; lib.optionalString (enable && (type == "fcitx5")) ''
    include "${fcitx5Kdl}"
    ''}

  '';
}
# wrap in nixGL to fix OpenGL under nix in non-Nixos systems
// (lib.optionalAttrs aln.ctx.host.is.generic-linux { # no need to install on nixos (we do so system wide)
  home.packages = [ (config.lib.nixGL.wrap pkgs.niri) ];
})

# NOTE: Assuming user does not have sudo priviledges,
# to get niri to start, log in via TTY and run niri-session
# This will start a "niri" as a systemd service in the TTY
# If user does have sudo priviledges, place below in /usr/share/wayland-session/niri.desktop (at least for GDM) then select Niri when login
/*
[Desktop Entry]
Name=Niri
Comment=A scrollable-tiling Wayland compositor
Exec=niri-session
Type=Application
DesktopNames=niri
*/
