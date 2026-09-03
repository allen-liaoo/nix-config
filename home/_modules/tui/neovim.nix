{
  lib,
  pkgs,
  config,
  inputs,
  alnLib,
  ...
}:

let
  nvimxPkg =
    with inputs.nvimx;
    makeNvimxWithModule (pkgs.stdenv.hostPlatform.system) {
      nvimx.treesitter.enableAllGrammars = true;
      nvimx.preset.nix.enable = true;
      nvimx.preset.rust.enable = true;
      nvimx.preset.shells.enable = true;
    };
in
{
  home.packages = [
    nvimxPkg
    pkgs.wl-clipboard
  ];

  programs.fish.shellAliases = {
    "v" = lib.mkForce "nvim";
    "vi" = lib.mkForce "nvim";
    "vim" = lib.mkForce "nvim";
  };

  home.sessionVariables = {
    "EDITOR" = lib.mkForce "nvim";
    "VISUAL" = lib.mkForce "nvim";
  };

  # CodeCompanion's claude_code adapter (see nvimx) reads CLAUDE_CODE_OAUTH_TOKEN
  sops.secrets.claude_code_oauth_token = {
    sopsFile = alnLib.relToRoot "secrets/user/allenl/common.yaml";
    key = "claude_code_oauth_token";
  };

  sops.templates.claude_code_oauth_token_env.content = ''
    CLAUDE_CODE_OAUTH_TOKEN=${config.sops.placeholder.claude_code_oauth_token}
  '';

  systemd.user.services.claude-code-oauth-token-env = {
    Unit = {
      Description = "Import CLAUDE_CODE_OAUTH_TOKEN into the systemd user session";
      Before = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session-pre.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = toString (
        pkgs.writeShellScript "import-claude-code-oauth-token" ''
          set -a
          . ${config.sops.templates.claude_code_oauth_token_env.path}
          set +a
          systemctl --user set-environment CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN"
        ''
      );
    };
    Install.WantedBy = [ "graphical-session-pre.target" ];
  };
}
