{ inputs, self }:

{
  name,
  system ? "x86_64-linux",
  kind ? "nixos",
}:

let
  inherit (inputs.nixpkgs) lib;

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
    ../modules
    {
      networking.hostName = lib.mkDefault name;
    }
    ../hosts/${name}.nix
  ];
}
