{ ... }:

{
  programs.firefox.profiles.default.extraConfig = ''
    user_pref("WaveFox.Tabs.Shape", 8);
    user_pref("WaveFox.Tabs.Separators", 2);
  '';

  home.file.".mozilla/firefox/default/chrome".source = ./WaveFox/chrome;
}
