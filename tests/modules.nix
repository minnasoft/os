{ lib, pkgs }:

let
  files = import ../lib/files.nix { inherit lib; };
  discovered = files.discover { dir = ./fixtures/modules; };
in
assert lib.assertMsg (lib.elem ./fixtures/modules/root.nix discovered)
  "module discovery should include regular Nix files";
assert lib.assertMsg (lib.elem ./fixtures/modules/nested/inner.nix discovered)
  "module discovery should include nested Nix files";
assert lib.assertMsg (
  !(lib.elem ./fixtures/modules/default.nix discovered)
) "module discovery should ignore default.nix";
assert lib.assertMsg (
  !(lib.elem ./fixtures/modules/_scratch.nix discovered)
) "module discovery should ignore underscore-prefixed files";
assert lib.assertMsg (
  !(lib.elem ./fixtures/modules/_ignored/inner.nix discovered)
) "module discovery should ignore underscore-prefixed directories";
assert lib.assertMsg (
  !(lib.elem ./fixtures/modules/notes.txt discovered)
) "module discovery should ignore non-Nix files";
assert lib.assertMsg (
  builtins.length discovered == 2
) "module discovery should only return imported modules";
pkgs.runCommand "module-discovery-tests" { } ''
  touch $out
''
