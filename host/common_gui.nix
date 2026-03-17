{ pkgs, customLib, ... }:
{
  imports = [
    ./common.nix
  ] ++ (map customLib.relToRoot (
    map (p: "modules/nixos/" + p) [
      "font.nix"
    ]
  ));
}
