{
  lib,
  config,
  ...
}:

lib.mkIf config.aln.app.enable {
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
  };
}
