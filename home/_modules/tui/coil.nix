{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.aln.shell.package.configuration.tools) nvimx;
  termfilechooser = nvimx.config.plugins.coil.termfilechooser.package;
in
{
  # use coil as terminal file chooser
  xdg.configFile."xdg-desktop-portal-termfilechooser/config" = lib.mkIf config.aln.de.enable {
    text = lib.mkForce ''
      [filechooser]
      cmd=${lib.getExe termfilechooser}
      default_dir=$HOME
      create_help_file=1
      open_mode=suggested
      save_mode=suggested
      env=TERMCMD='${lib.getExe config.programs.kitty.package} --title "Terminal Filechooser"'
    '';
    # the portal only reads its config on startup, and its unit isn't HM-managed so a switch won't
    # restart it
    onChange = ''
      ${pkgs.systemd}/bin/systemctl --user try-restart xdg-desktop-portal-termfilechooser.service || true
    '';
  };
}
