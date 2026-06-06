{
  lib,
  config,
  ...
}:

lib.mkIf config.aln.io.enable {
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
