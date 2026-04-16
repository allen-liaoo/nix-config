{ lib, pkgs, config, aln, ... }:

let 
  symlinkTo = f: f |> aln.lib.outOfStoreRelToRoot config.home.homeDirectory |> config.lib.file.mkOutOfStoreSymlink;
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

    ${lib.optionalString (config.programs.dank-material-shell.enable) ''
    // Open terminal in single column
    window-rule {
      match app-id=r#"Alacritty"#
      open-maximized false
      open-maximized-to-edges false
    }''}
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
