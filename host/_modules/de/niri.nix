{ lib, pkgs, ... }:

{
  programs.niri.enable = true;
  hardware.graphics.enable = true;

  # greeter
  environment.systemPackages = with pkgs; [ tuigreet ];
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "tuigreet --theme border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red --asterisks --time --remember --cmd niri";
      user = "pig";
    };
  };
}
