{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.aln.app.enable {
  programs.kitty = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.kitty;
    # dms managed matugen theme (dank-theme.conf, dank-tabs.conf); before settings so ours win
    # (dms appends background_opacity to it). globinclude, so a missing file isn't an error
    extraConfig = lib.mkIf config.programs.dank-material-shell.enable (
      lib.mkOrder 500 "globinclude dank-*.conf"
    );
    # keep the block cursor (shell integration would switch it to a beam at the prompt)
    shellIntegration.mode = "no-cursor";
    settings = {
      window_padding_width = 6; # pt, ~8px
      hide_window_decorations = true;
      background_opacity = "0.75";
      cursor_shape = "block";
      cursor_blink_interval = 0;
      # OSC 52 read and write without prompting
      clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
      # tmux is always running, don't ask on every close
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      # tmux does windows/tabs/layouts/scrollback: drop all of kitty's shortcuts (keeping only
      # the ones below) and show a single window, no tab bar, in case one gets created anyway.
      # This also frees C-S-hjkl, which kitty already sends as CSI u
      clear_all_shortcuts = true;
      enabled_layouts = "stack";
      tab_bar_style = "hidden";
    };
    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "shift+insert" = "paste_from_selection";
      "ctrl+shift+equal" = "change_font_size all +2.0";
      "ctrl+shift+minus" = "change_font_size all -2.0";
      "ctrl+shift+backspace" = "change_font_size all 0";
      "ctrl+shift+e" = "open_url_with_hints";
      "ctrl+shift+f5" = "load_config_file";
    };
    # tells fish to start tmux (see shell/tmux-autostart.nix)
    environment.ALN_TMUX_AUTOSTART = "1";
  };

  programs.dank-material-shell.settings.matugenTemplateKitty = true;

  aln.niri.configFile."kitty" = {
    enable = true;
    content = ''
      binds {
        Mod+T hotkey-overlay-title="Open Terminal: Kitty" {
          spawn "${lib.getExe config.programs.kitty.package}";
        }
      }
      window-rule {
        match app-id=r#"kitty"#
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
