{ ... }:

{
  # xremap need uinput support
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];
  # users of xremap need to be in input group
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", TAG+="uaccess"
  '';
}
