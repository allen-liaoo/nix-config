{ lib, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      scrollback.lines = 10000;
      cursor = {
        style = "block";
        blink = "yes";
      };
    };
  };
}
