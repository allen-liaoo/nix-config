{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    dejavu_fonts
    adwaita-fonts
    nerd-fonts.commit-mono
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [
        "DejaVu Serif"
        "Noto Serif CJK TC"
        "Noto Serif CJK SC"
      ];
      sansSerif = [
        "Adwaita Sans"
        "Noto Sans CJK TC"
        "Noto Sans CJK SC"
      ];
      monospace = [
        "CommitMono Nerd Font Mono"
        "Noto Sans Mono CJK TC"
        "Noto Sans Mono CJK SC"
      ];
      emoji = [
        "Noto Color Emoji"
      ];
    };
  };
}
