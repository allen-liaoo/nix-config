{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    shellWrapperName = "y"; # new in 26.05

    settings = {
      mgr = {
        show_hidden = false;
        sort_dir_first = true;
        sort_by = "extension";
        show_symlink = true;
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "M";
          run = "plugin mount";
          desc = "View mounts";
        }
        {
          on = "T";
          run = "plugin omni-trash";
          desc = "View trash";
        }
      ];
    };

    plugins = {
      mount = pkgs.yaziPlugins.mount;
      omni-trash = pkgs-unstable.yaziPlugins.omni-trash; # TODO: switch to stable
      yatline = {
        package = pkgs.yaziPlugins.yatline;
        setup = true;
      };
    };

    extraPackages = with pkgs; [
      trash-cli    # required by omni-trash
    ];
  };

  # Yazi specific init (replaces the need for abbreviation)
  # press q to quit with auto cd; press Q to quit without cd
  programs.fish.interactiveShellInit = ''
    function y
      set tmp (mktemp -t "yazi-cwd.XXXXXX")
      yazi $argv --cwd-file="$tmp"
      if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
      end
      rm -f -- "$tmp"
    end
  '';

  # use yazi as terminal file chooser
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
    default_dir=$HOME
    create_help_file=1
    open_mode=suggested
    save_mode=suggested
    env=TERMCMD='${lib.getExe config.programs.alacritty.package} -T "Terminal Filechooser" -e'
  '';

  aln.matugen.template."yazi" = {
    enable = true;
    content = {
      input_path = config.aln.matugen.themesPath "yazi-theme.toml";
      output_path = config.xdg.configHome + "/yazi/theme.toml";
    };
    # no support for live reloading yet
  };
}
