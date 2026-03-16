{ ... }:
{
  # Import all files in a directory, excluding default.nix. Non-recurive
  importDir = (dir:
    let
      files = builtins.readDir dir;
      nixFiles = builtins.filter
        (name: name != "default.nix" && builtins.match ".*\\.nix" name != null)
        (builtins.attrNames files);
    in map (name: dir + "/${name}") nixFiles
  );

  # Import all immediate subdirectory of current directory
  importSubdirs = (dir:
    let
      entries = builtins.readDir dir;
      subdirs = builtins.filter
        (name: entries.${name} == "directory")
        (builtins.attrNames entries);
    in map (name: dir + "/${name}") subdirs
  );
}
