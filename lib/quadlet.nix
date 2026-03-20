# Templates for quadlet units
# see https://seiarotg.github.io/quadlet-nix/home-manager-options.html for options
{...}:

let 
  restartDefault = {
    unitConfig = {
      # Allow at most 5 restarts in 30s, then permanently give up
      StartLimitIntervalSec = 30;
      StartLimitBurst = 5;
    };
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 3;
      RestartSteps = 4; # rate of exponential timeout
      RestartMaxDelaySec = 300; # max timeout
    };
  };
in {
  mkContainer = (name: config: {
    autoStart = true;
    containerConfig = {
      inherit name;
      autoUpdate = "registry";
      logDriver = "journald";
      noNewPrivileges = true;
      startWithPod = true;
    };
    quadletConfig.defaultDependencies = true;
  } // restartDefault // config);

  mkImage = (name: config: {
    autoStart = true;
    imageConfig = {
      name = "${name}-image";
      retry = 3;
    };
  } // restartDefault // config);
 
  mkNetwork = (name: config: {
    autoStart = true;
    networkConfig = {
      name = "${name}-network";
      disableDns = false;
    };
  } // restartDefault // config);

  mkPod = (name: config: {
    autoStart = true;
    podConfig = {
      name = name; # can't add -pod postfix as pod name must be unique, so postfix must be in the input name
      disableDns = false;
      exitPolicy = "stop";
      stopTimeout = "120"; # kill units after timeout
    };
    serviceConfig = {
      Restart = "always";
      # with exitPolicy = stop, pod exists cleanly when all the container stops,
      # does not matter if container stops with failure. so set this as always
      RestartSec = "15min";
    };
  } // restartDefault // config);

  mkVolume = (name: config: {
    autoStart = true;
    volumeConfig = {
      name = "${name}-volume";
      copy = true;
      device = "tmpfs";
    };
  } // restartDefault // config);
}
