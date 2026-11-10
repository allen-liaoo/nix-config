{
  config,
  pkgs,
  pkgs-aln,
  lib,
  ...
}:

let
  # out of store (a string, not a path) so matugen can rewrite it
  flavor = "${config.xdg.stateHome}/matugen/yazi/matugen.yazi";
in
{
  # use yazi as terminal file chooser
  xdg.configFile."xdg-desktop-portal-termfilechooser/config" = {
    text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
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

  aln.matugen.template."yazi" = {
    enable = config.aln.de.enable;
    content = {
      input_path = config.aln.matugen.themesPath "yazi-theme.toml";
      output_path = "${flavor}/flavor.toml";
    };
    # no support for live reloading yet
  };

  aln.shell.module = lib.mkIf config.aln.de.enable {
    tools.yazi = pkgs-aln.yazi.wrap { theme = flavor; };
  };
}
