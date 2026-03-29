{ lib, config, aln, ... }:

{
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./config.kdl);
}
