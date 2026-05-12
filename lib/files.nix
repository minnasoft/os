{ lib }:

let
  ignored = name: name == "default.nix" || lib.hasPrefix "_" name;

  discover =
    {
      dir,
      recursive ? true,
    }:
    lib.flatten (
      lib.mapAttrsToList (
        name: type:
        let
          path = dir + "/${name}";
        in
        if ignored name then
          [ ]
        else if recursive && type == "directory" then
          discover {
            dir = path;
            inherit recursive;
          }
        else if type == "regular" && lib.hasSuffix ".nix" name then
          [ path ]
        else
          [ ]
      ) (builtins.readDir dir)
    );
in
{
  inherit discover;
}
