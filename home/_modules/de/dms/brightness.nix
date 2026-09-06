{
  lib,
  pkgs,
  config,
  ...
}:

let
  gammarelay = pkgs.wl-gammarelay-rs;

  # Routes XF86MonBrightness{Up,Down} based on whichever output last had focus:
  # the laptop panel (eDP-*) keeps using dms's real backlight control, anything
  # else falls back to gamma-based software dimming via wl-gammarelay-rs, since
  # we can't assume an external monitor supports DDC/CI.
  brightnessKey = pkgs.writeShellApplication {
    name = "niri-brightness-key";
    runtimeInputs = with pkgs; [ jq ];
    text = ''
      direction=$1 # increment | decrement
      step=$2      # percent, e.g. 5

      output=$(niri msg -j focused-output | jq -r '.name')

      if [[ "$output" == eDP* ]]; then
        exec ${lib.getExe config.programs.dank-material-shell.package} ipc call brightness "$direction" "$step" ""
      fi

      delta=$(${lib.getExe pkgs.gawk} -v s="$step" 'BEGIN { printf "%f", s / 100 }')
      if [[ "$direction" == "decrement" ]]; then
        delta="-''${delta}"
      fi

      exec busctl --user -- call rs.wl-gammarelay \
        "/outputs/''${output//-/_}" rs.wl.gammarelay UpdateBrightness d "$delta"
    '';
  };
in
lib.mkIf config.aln.de.enable {
  home.packages = [ gammarelay ];

  systemd.user.services.wl-gammarelay-rs = {
    Unit = {
      After = [ "niri.service" ];
      PartOf = [ "niri.service" ];
    };
    Service = {
      ExecStart = lib.getExe gammarelay;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "niri.service" ];
  };

  aln.niri.configFile."brightness" = {
    enable = true;
    content = ''
      binds {
        XF86MonBrightnessUp allow-when-locked=true {
          spawn "${lib.getExe brightnessKey}" "increment" "5";
        }
        XF86MonBrightnessDown allow-when-locked=true {
          spawn "${lib.getExe brightnessKey}" "decrement" "5";
        }
      }
    '';
  };
}
