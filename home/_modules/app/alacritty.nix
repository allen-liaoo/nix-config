{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.aln.app.enable {
  programs.alacritty = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.alacritty;
    settings = {
      general = {
        live_config_reload = true;
        # dms managed matugen theme
        import = lib.optionals config.programs.dank-material-shell.enable [
          (config.xdg.configHome + "/alacritty/dank-theme.toml")
        ];
      };
      window = {
        padding = {
          x = 8;
          y = 8;
        };
        decorations = "None";
        opacity = lib.mkForce 0.75;
      };
      cursor.style.shape = "Block";
      terminal.osc52 = "CopyPaste";
      # tells fish to start tmux (see below)
      env.ALN_TMUX_AUTOSTART = "1";
    };
  };

  # new tmux session per window, back in fish once tmux exits/detaches;
  # `alacritty -e <cmd>` still bypasses this. Erased first so nested shells don't start tmux
  aln.shell.module.integrations.alacritty.interactiveInit = ''
    if set -q ALN_TMUX_AUTOSTART; and not set -q TMUX
      set -e ALN_TMUX_AUTOSTART
      tmux new-session
    end
  '';

  programs.dank-material-shell.settings.matugenTemplateAlacritty = true;

  aln.niri.configFile."alacritty" = {
    enable = true;
    content = ''
      binds {
        Mod+T hotkey-overlay-title="Open a Terminal" {
          spawn "${lib.getExe config.programs.alacritty.package}";
        }
      }
      window-rule { 
        match app-id=r#"Alacritty"#
        // Open terminal in single column
        open-maximized true 
        open-maximized-to-edges false
        background-effect {
          blur true
          xray true
        }
      }
    '';
  };
}
