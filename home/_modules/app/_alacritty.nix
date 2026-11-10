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
      # tmux only requests modifyOtherKeys (not kitty keys), which alacritty doesn't support, so
      # C-S-hjkl would arrive as plain C-hjkl; send them as CSI u explicitly
      keyboard.bindings =
        lib.mapAttrsToList
          (key: code: {
            inherit key;
            mods = "Control|Shift";
            chars = builtins.fromJSON ''"\u001b[${toString code};6u"'';
          })
          {
            H = 104;
            J = 106;
            K = 107;
            L = 108;
          };
      # tells fish to start tmux (see shell/tmux-autostart.nix)
      env.ALN_TMUX_AUTOSTART = "1";
    };
  };

  programs.dank-material-shell.settings.matugenTemplateAlacritty = true;

  aln.niri.configFile."alacritty" = {
    enable = true;
    content = ''
      binds {
        Mod+T hotkey-overlay-title="Open Terminal: Alacritty" {
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
