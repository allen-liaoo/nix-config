{
  pkgs ? import <nixpkgs> { },
}:
let
  # Runs SecureW2_JoinNow.run inside an FHS env
  joinnow = pkgs.buildFHSEnv {
    name = "securew2-joinnow";
    targetPkgs =
      pkgs:
      (with pkgs; [
        (python3.withPackages (ps: [ ps.dbus-python ])) # Run embedded Python code
        coreutils # Needs uname to identify architecture
        gnutar # Needed to extract emebedded archive
        libx11 # for GUI
        openssl # Required during Python import
        simpleTpmPk11 # Unknown use
        which # Used by shell script to find programs
        xdg-utils # Used by Python script to open links
        xwininfo # Unknown use
      ]);
    runScript = pkgs.writeShellScript "securew2-joinnow-run" ''
      exec ${pkgs.bash}/bin/sh ${./SecureW2_JoinNow.run} "$@"
    '';
  };

  # wpa_supplicant runs as its own unprivileged user, so grant it read access to the
  # enrolled .p12 key afterwards. Must run outside the FHS env: its user namespace only
  # maps the current uid, so setfacl can't reference wpa_supplicant's uid there.
  grant-wpa-access = pkgs.writeShellApplication {
    name = "grant-wpa-access";
    runtimeInputs = [ pkgs.acl ];
    text = builtins.readFile ./grant-wpa-access.sh;
  };
in
pkgs.mkShell {
  packages = [
    joinnow
    grant-wpa-access
  ];
}
