{ lib, pkgs, aln, ...}:

{
  stylix = {
    enable = true;
    autoEnable = true; # auto enable targets
    base16Scheme = "${pkgs.base16-schemes}/share/themes/snazzy.yaml";
    image = aln.lib.relToRoot "assets/wallpaper/wallpaper-night.jpg";
    imageScalingMode = "fill";
    #polarity = "dark"; # for theme gen based on image if base scheme unset

    #base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-city-light.yaml";
    #image = aln.lib.relToRoot "assets/wallpaper/wallpaper-light.jpeg";

    # stylix adds fonts to certain programs who don't read from fontconfig
    # but doesnt support fallbacks (for now)
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "Dejavu Serif";
      };
      sansSerif = {
        package = pkgs.adwaita-fonts;
        name = "Adwaita Sans";
      };
      monospace = {
        package = pkgs.nerd-fonts.commit-mono;
        name = "Commit Mono Nerd Font";
      };
    };
  };
}
