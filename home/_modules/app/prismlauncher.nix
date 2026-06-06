{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  prismlauncher-wrapped = pkgs.symlinkJoin {
    name = "prismlauncher-wrapped";
    paths = [ pkgs-unstable.prismlauncher ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = with pkgs; ''
      wrapProgram $out/bin/prismlauncher \
        --set XDG_DATA_DIRS "${glib.getSchemaPath gsettings-desktop-schemas}:${gtk3}/share/gsettings-schemas/${gtk3.name}"
    '';
  };
in
lib.mkIf config.aln.app.enable {
  home.packages = with pkgs; [
    prismlauncher-wrapped
  ];

  aln.niri.configFile."prismlauncher" = {
    enable = true;
    content = ''
      window-rule {
        match app-id=r#"^Minecraft.*"#
        open-fullscreen true
      }
    '';
  };
}
