{ lib, ... }:

let
  files = import ../lib/files.nix { inherit lib; };
in
{
  imports = files.discover { dir = ./.; };

  system.stateVersion = lib.mkDefault "26.05";
}
