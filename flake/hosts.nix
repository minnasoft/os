{ inputs, self, ... }:

let
  inherit (inputs.nixpkgs) lib;

  mkHost = import ../lib/mk-host.nix { inherit inputs self; };

  metadata = import ../hosts;
  default = metadata._default or { };

  # NOTE: `hosts/foo.nix` becomes `nixosConfigurations.foo`.
  isHostFile =
    name: type:
    type == "regular"
    && lib.hasSuffix ".nix" name
    && name != "default.nix"
    && !(lib.hasPrefix "_" name);

  names = lib.mapAttrsToList (name: _: lib.removeSuffix ".nix" name) (
    lib.filterAttrs isHostFile (builtins.readDir ../hosts)
  );

  mkConfig = name: {
    inherit name;
    value = mkHost (default // (metadata.${name} or { }) // { inherit name; });
  };
in
{
  flake.nixosConfigurations = builtins.listToAttrs (map mkConfig names);
}
