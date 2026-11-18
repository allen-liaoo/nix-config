{
  lib,
  config,
  ...
}:

lib.mkIf config.aln.de.enable {
  programs.dank-material-shell.settings = {
    dashTabs = [
      {
        id = "overview";
        enabled = true;
      }
      {
        id = "media";
        enabled = true;
      }
      {
        id = "weather";
        enabled = true;
      }
      {
        id = "wellbeing";
        enabled = true;
      }
      {
        id = "wallpaper";
        enabled = true;
      }
      {
        id = "notifications";
        enabled = false;
      }
    ];
     
    # dashboard overview cards
    dashCards = [
      {
        id = "notifications";
        w = 3;
        h = 5;
        col = 3;
        row = 0;
      }
      {
        id = "calendar";
        w = 3;
        h = 4;
        col = 0;
        row = 0;
      }
      {
        id = "sysmon";
        w = 3;
        h = 1;
        col = 0;
        row = 4;
      }
    ];

    dashOptions = {
      media = {
        playerStyle = "material";
        panelRows = 6;
        waveProgress = false;
      };
      weather = {
        widgets = [
          {
            id = "conditions";
            w = 2;
            h = 2;
            tone = "primary";
            city = true;
            col = 0;
            row = 0;
          }
          {
            id = "hourly";
            w = 4;
            h = 2;
            forecast = "chart";
            col = 0;
            row = 2;
          }
          {
            id = "wind";
            w = 1;
            h = 2;
            graphics = true;
            tone = "";
            col = 3;
            row = 0;
          }
          {
            id = "precipitation";
            w = 1;
            h = 2;
            graphics = true;
            tone = "";
            col = 2;
            row = 0;
          }
          {
            id = "daily";
            w = 4;
            h = 2;
            forecast = "chart";
            col = 0;
            row = 4;
          }
        ];
      };
      calendar = {
        weekends = true;
      };
      wellbeing = {
        panelRows = 6;
      };
    };
  };
}
