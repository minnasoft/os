{ inputs, self, ... }:

let
  hosts = import ../lib/hosts.nix { inherit inputs self; };
in
{
  # NOTE: `hosts/foo.nix` becomes `nixosConfigurations.foo`.
  flake.nixosConfigurations = hosts.mkHosts {
    dir = ../hosts;
    metadata = import ../hosts;
  };
}
