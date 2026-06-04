{
  lib,
  pkgs,
  pkgs-aln,
  ctx,
  inventory,
  ...
}:

{
  programs.mcp = {
    enable = true;
    servers = {
      nix = {
        type = "local";
        command = lib.getExe pkgs.mcp-nixos;
      };
      typst = lib.mkIf (ctx.host.equals inventory.hosts.theseus) {
        type = "local";
        command = lib.getExe pkgs-aln.typst-mcp;
      };
    };
  };
}
