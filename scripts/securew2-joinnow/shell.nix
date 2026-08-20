{
  pkgs ? import <nixpkgs> { },
}:
(pkgs.buildFHSEnv {
  name = "securew2-fhsenv";
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
  runScript = ./SecureW2_JoinNow.run;
}).env

