{ lib, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "CommitMonoNerdFont:size=12";
      };
      scrollback.lines = 10000;
      cursor = {
        style = "block";
        blink = "yes";
      };
    };
  };
}
