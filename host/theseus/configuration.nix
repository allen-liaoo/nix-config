{ inputs, lib, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  # Since I swapped MediaTek WIFI card with Intel AX210
  hardware.enableRedistributableFirmware = true;

  # Remap airplane key (F10) from KEY_RFKILL to KEY_PROG1 (XF86Launch1) so the kernel's rfkill-input handler stops toggling all radios on press
  services.udev.extraHwdb = ''
    evdev:input:b0018v32ACp0006*
     KEYBOARD_KEY_100c6=prog1
  '';

  services.automatic-timezoned.enable = true;
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
  };

  # LUKS devices
  boot.initrd.luks.devices = {
    cryptroot = {
      device = lib.mkForce "/dev/disk/by-partlabel/disk-main-luks"; # conflicts with disko
      allowDiscards = true;
    };
    cryptswap = {
      device = "/dev/disk/by-partlabel/disk-main-swap";
      allowDiscards = true;
    };
  };

  boot.tmp.useTmpfs = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # memoryPercent defaults to 50
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
}
