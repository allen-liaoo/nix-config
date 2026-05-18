{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
  # sleekCss = pkgs.fetchFromGitHub {
  #   owner = "spicetify";
  #   repo = "spicetify-themes";
  #   rev = "9af41cf91af6f6093c0e060d57264f08f6bb161c";
  #   hash = "sha256-UznMAqk0Kdu1GkiIegWQKvtvZ1eEB9jLcHfR2ad10mQ=";
  #   sparseCheckout = [
  #     "/Sleek/user.css"
  #   ];
  # };
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify 
  ];

  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      hidePodcasts
      sidebarCustomizer
    ];
    updateXpui = prevXpui: lib.recursiveUpdate prevXpui {
      AdditionalOptions = {
        current_theme = "Sleek";
        color_scheme = "matugen";
      };
    };
  };

  home.packages = [
    config.programs.spicetify.spicetifyPackage
  ];

  # TODO: figure out wrapping spicetify for matugen
  # aln.matugen.template."spicetify" = {
  #   enable = true;
  #   content = {
  #     input_path = config.aln.matugen.themesPath "spicetify.ini";
  #     output_path = "${config.xdg.configHome}/spicetify/Themes/Sleek/color.ini";
  #     post_hook = ''spicetify watch -s 2>&1 | sed "/Reloaded Spotify/q"'';
  #   };
  # };
  # xdg.configFile."spicetify/Themes/Sleek/user.css".source = "${sleekCss}/Sleek/user.css";
}
