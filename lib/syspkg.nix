# system dependent lib
{ pkgs, nixpkgs, ... }:

{
  fromYaml = file: builtins.fromJSON (builtins.readFile (
    pkgs.runCommand "yaml-to-json" {} ''
      ${pkgs.yq-go}/bin/yq -o json ${file} > $out
    ''
  ));
}
