{
  lib,
  config,
  ...
}:

lib.mkIf config.aln.de.enable {
  programs.dank-material-shell.settings = {
    # Without this, HM's declarative settings.json lacks configVersion, so DMS
    # treats it as version 0 on every switch and re-runs its migration chain -
    # the v4 step unconditionally rebuilds desktopWidgetInstances from legacy
    # keys (which we don't set), wiping this declared widget to [] at startup.
    configVersion = 4;
    desktopWidgetInstances = [
      {
        id = "dw_weather";
        widgetType = "dankDesktopWeather";
        name = "Dank Desktop Weather";
        enabled = true;
        config = {
          displayPreferences = [
            "all"
          ];
          viewMode = "detailed";
          colorMode = "primary";
          forecastDays = 7;
          backgroundOpacity = 0;
          showCondition = false;
          showForecast = true;
          showHourlyForecast = true;
          hourlyCount = 6;
          showLocation = false;
          showHumidity = true;
          showWind = true;
          showPrecipitation = true;
          syncPositionAcrossScreens = true;
        };
      }
      # {
      #   id = "dw_album";
      #   widgetType = "dankAlbumWidget";
      #   name = "Dank Album Widget";
      #   enabled = true;
      #   config = {
      #     displayPreferences = [
      #       "all"
      #     ];
      #     syncPositionAcrossScreens = true;
      #     hideWhenIdle = true;
      #   };
      # }
      {
        id = "dw_sysmon";
        widgetType = "systemMonitor";
        name = "System Monitor";
        enabled = true;
        config = {
          showHeader = true;
          transparency = 0.11;
          colorMode = "primary";
          showCpu = true;
          showCpuGraph = true;
          showCpuTemp = true;
          showGpuTemp = true;
          gpuPciId = "";
          showMemory = true;
          showMemoryGraph = true;
          showNetwork = true;
          showNetworkGraph = true;
          showDisk = true;
          showTopProcesses = false;
          # topProcessCount = 3;
          # topProcessSortBy = "memory";
          layoutMode = "list";
          graphInterval = 300;
          displayPreferences = [
            "all"
          ];
          showOnOverlay = false;
          showOnOverview = false;
          syncPositionAcrossScreens = true;
          clickThrough = false;
        };
      }
    ];
  };

  programs.dank-material-shell.session.desktopWidgetInstancePositions = {
    dw_sysmon._synced = {
      # Bottom-right-corner placement, generalized to any screen: DMS clamps the
      # saved position into [0, screenSize - widgetSize] on render, and with
      # syncPositionAcrossScreens the saved x/y are fractions of that screen's
      # size (width/height stay raw px). A fraction of 1 always resolves above
      # the clamp ceiling, so it snaps to exactly flush-right/flush-bottom on
      # whatever monitor is current
      x = 1;
      y = 1;
      width = 320;
      height = 480;
    };
    dw_weather._synced = {
      x = 0;
      y = 1;
      width = 470;
      height =  470;
    };
  };
}
