{ lib, pkgs }:

let
  hosts = import ../lib/hosts.nix {
    inputs.nixpkgs.lib = lib;
    self = null;
  };

  discovered = hosts.discover ./fixtures/hosts;

  metadata = {
    _default = {
      name = "wrong";
      system = "x86_64-linux";
      kind = "nixos";
    };

    vm = {
      name = "also-wrong";
      system = "aarch64-linux";
    };
  };

  vm = hosts.hostConfig metadata "vm";

  configs = hosts.mkHosts {
    dir = ./fixtures/hosts;
    inherit metadata;
    buildHost = host: host;
  };
in
assert lib.assertMsg (
  discovered == [ "vm" ]
) "discover should ignore default.nix and underscore-prefixed files";
assert lib.assertMsg (vm.name == "vm") "hostConfig should force the discovered host name";
assert lib.assertMsg (
  vm.system == "aarch64-linux"
) "hostConfig should allow host metadata to override defaults";
assert lib.assertMsg (
  vm.kind == "nixos"
) "hostConfig should keep default metadata when host metadata omits it";
assert lib.assertMsg (
  configs.vm.hostModule == ./fixtures/hosts/vm.nix
) "mkHosts should pass the discovered host path to mkHost";
pkgs.runCommand "host-discovery-tests" { } ''
  touch $out
''
