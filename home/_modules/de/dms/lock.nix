{
  lib,
  config,
  ...
}:

lib.mkIf config.aln.de.enable {
  programs.dank-material-shell.settings = {
    lockScreenShowPowerActions = true;

    lockScreenWidgetInstances = [
      {
        id = "lock_clock";
        widgetType = "desktopClock";
        enabled = true;
        config = {
          displayPreferences = [
            "all"
          ];
          syncPositionAcrossScreens = true;
          style = "overlap";
          transparency = 0;
          weight = 100;
          twoTone = true;
          showDate = false;
          showDigitalSeconds = false;
          showAnalogNumbers = false;
          showAnalogSeconds = true;
          autoPosition = false;
          colorMode = "default";
          customColor = "#ffffff";
          fontFamily = "CommitMono Nerd Font Mono";
        };
      }
      {
        id = "lock_date";
        widgetType = "lockDate";
        enabled = true;
        config = {
          displayPreferences = [
            "all"
          ];
          syncPositionAcrossScreens = true;
          format = "short";
          colorMode = "default";
          customColor = "#ffffff";
        };
      }
      {
        id = "lock_auth";
        widgetType = "lockAuth";
        enabled = true;
        config = {
          displayPreferences = [
            "all"
          ];
          syncPositionAcrossScreens = true;
          style = "dots";
          profileVisibility = "always";
          passwordVisibility = "always";
        };
      }
      {
        id = "lock_notifications";
        widgetType = "lockNotifications";
        enabled = true;
        config = {
          displayPreferences = [
            "all"
          ];
          syncPositionAcrossScreens = true;
          mode = 2;
        };
      }
      {
        id = "lock_status";
        widgetType = "lockStatus";
        enabled = true;
        config = {
          displayPreferences = [
            "all"
          ];
          syncPositionAcrossScreens = true;
          showMediaPlayer = true;
          showWeather = true;
          background = false;
        };
      }
      {
        # DMS's own default id for this type; the UI would otherwise mint a
        # random lw_<timestamp>_<rand> id when adding it
        id = "lock_power";
        widgetType = "lockPower";
        enabled = true;
        config = {
          displayPreferences = [
            "all"
          ];
          syncPositionAcrossScreens = true;
          shape = "round";
        };
      }
    ];
  };

  programs.dank-material-shell.session.desktopWidgetInstancePositions = {
    lock_clock._synced = {
      x = 0;
      y = -0.14557342529296874;
      anchorX = "center";
      anchorY = "center";
      width = 357.5;
      height = 427.33203125;
    };
    lock_auth._synced = {
      x = 0;
      y = 0.084375;
      anchorX = "center";
      anchorY = "center";
    };
    # top-left corner
    lock_date._synced = {
      x = 0.0125;
      y = 0.01875;
      width = 120;
      height = 40;
    };
    # bottom-right corner, same inset as lock_date
    lock_power._synced = {
      x = 0.0125;
      y = 0.01875;
      anchorX = "end";
      anchorY = "end";
    };
  };
}
