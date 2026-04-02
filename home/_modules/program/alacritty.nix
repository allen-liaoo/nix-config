{ ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      general.live_config_reload = true;
      window = {
        padding = { x = 5; y = 5; };
        decorations = "None";
      };
      terminal.osc52 = "OnlyCopy"; # for copying from remote server
    };
  };
}
