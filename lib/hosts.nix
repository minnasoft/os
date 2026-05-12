{ inputs, self }:

let
  inherit (inputs.nixpkgs) lib;

  files = import ./files.nix { inherit lib; };

  discover =
    dir:
    map (path: lib.removeSuffix ".nix" (builtins.baseNameOf path)) (
      files.discover {
        inherit dir;
        recursive = false;
      }
    );

  hostConfig =
    metadata: name:
    let
      default = metadata._default or { };
    in
    default // (metadata.${name} or { }) // { inherit name; };

  mkHost =
    {
      name,
      system ? "x86_64-linux",
      kind ? "nixos",
      hostModule,
      ...
    }:
    let
      # TODO: Support WSL and Darwin hosts.
      supportedKinds = [ "nixos" ];
    in
    assert lib.assertMsg (lib.elem kind supportedKinds) ''
      Unsupported host kind `${kind}` for `${name}`. Supported kinds: ${lib.concatStringsSep ", " supportedKinds}.
    '';
    lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs self;
      };

      modules = [
        inputs.home-manager.nixosModules.home-manager
        ../modules
        {
          networking.hostName = lib.mkDefault name;
        }
        hostModule
      ];
    };
in
{
  inherit discover hostConfig mkHost;

  mkHosts =
    {
      dir,
      metadata,
      buildHost ? mkHost,
    }:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = buildHost (hostConfig metadata name // { hostModule = dir + "/${name}.nix"; });
      }) (discover dir)
    );
}
