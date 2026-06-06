{
  config,
  lib,
  pkgs,
  ...
}:

let
  matugenThemes = pkgs.fetchFromGitHub {
    owner = "InioX";
    repo = "matugen-themes";
    rev = "c129e42458ec3dba210f98f26e84e51ae874e8a2";
    hash = "sha256-2zSQmi8g1uVr0viHPKSuxYDpVDykOYnDtmG6YP+XKMk=";
    sparseCheckout = [
      "/templates"
    ];
  };
  contentModule = {
    freeformType = lib.types.attrs;
    options = {
      input_path = lib.mkOption {
        type = lib.types.path;
      };
      output_path = lib.mkOption {
        type = lib.types.path;
      };
    };
  };
  templateModule = (
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption name;
        content = lib.mkOption {
          type = lib.types.submodule contentModule;
        };
      };
    }
  );
  tomlFormat = pkgs.formats.toml { };
in
{
  options = {
    aln.matugen = {
      template = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule templateModule);
        default = { };
      };
      themesPath = lib.mkOption {
        type = lib.types.functionTo lib.types.path;
        readOnly = true;
        default = path: "${matugenThemes}/templates/" + path;
        description = "Path to a matugen template in the official matugen-themes repository";
      };
    };
  };

  config = lib.mkIf config.aln.de.enable {
    xdg.configFile."matugen/config.toml".source = tomlFormat.generate "config.toml" {
      config = { };
      templates = (
        config.aln.matugen.template |> lib.filterAttrs (_: v: v.enable) |> lib.mapAttrs (_: v: v.content)
      );
    };
  };
}
