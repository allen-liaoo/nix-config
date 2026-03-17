{ pkgs, customLib, ... }:
{
  imports = [
    ./common.nix
  ] ++ (map customLib.relativeToRoot (
    map (p: "modules/nixos/" + p) [
      "font.nix"
    ]
  ));
}
