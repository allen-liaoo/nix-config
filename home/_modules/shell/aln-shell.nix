# fish + tools from alnpkgs (pkgs-aln.shell), specialized by the modules here
# through `aln.shell.module` (re-themed tools, extra integrations, ...)
{
  config,
  lib,
  pkgs,
  pkgs-aln,
  ...
}:

let
  cfg = config.aln.shell;
in
{
  options.aln.shell = {
    module = lib.mkOption {
      type = lib.types.deferredModule;
      default = { };
      description = ''
        Module applied with `pkgs-aln.shell.wrap`: replace `tools`, add `integrations`, etc.
        Any module may define it, e.g. `integrations.zellij.abbreviations.zj = "zellij";`.
      '';
    };
    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs-aln.shell.wrap cfg.module;
      description = "The final shell. Its tools are at `.configuration.tools`.";
    };
  };

  config = {
    # tools are also installed, for programs started outside fish and for completions
    home.packages = [
      cfg.package
    ]
    ++ lib.attrValues (lib.filterAttrs (_: t: t != null) cfg.package.configuration.tools);

    # fish as login shell breaks system, so use bash and launch fish if parent process is not fish
    # see: https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
    programs.bash.enable = true;
    programs.bash.initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        # home-manager's fish sourced these itself; the packaged fish inherits them from here
        . "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${lib.getExe cfg.package} $LOGIN_OPTION
      fi
    '';
  };
}
