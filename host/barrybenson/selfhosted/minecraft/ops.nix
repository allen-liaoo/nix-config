operators:
let
  players = import ./players.nix;
in
  builtins.mapAttrs
    (name: val:
      {
        uuid = builtins.getAttr name players;
      }
      // builtins.getAttr name operators
    )
    operators
