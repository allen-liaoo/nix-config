# Status: Not working
{ lib, config, pkgs, aln, ... }:

let 
  fcitx5-pkg = pkgs.kdePackages.fcitx5-with-addons;
in
{
  # i18n.inputMethod = {
  #   enable = true;
  #   type = "fcitx5";
  #   fcitx5 = {
  #     fcitx5-with-addons = fcitx5-pkg;
  #     waylandFrontend = true;
  #     addons = with pkgs; [ fcitx5-rime ];
  #   };
  # };

  # https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland

  # systemd.user.services."fcitx5-daemon".Service = {
  #   ExecStart = lib.mkForce ''
  #      ${fcitx5-pkg}/bin/fcitx5 --enable rime --verbose default=debug
  #   '';
  # };

  xdg.dataFile."fcitx5/rime/default.custom.yaml".source = config.lib.file.mkOutOfStoreSymlink (aln.lib.outOfStoreRelToRoot config.home.homeDirectory ./default.custom.yaml);
}
