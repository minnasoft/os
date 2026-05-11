{ lib, ... }:

{
  imports = [
    ./os.nix
  ];

  system.stateVersion = lib.mkDefault "26.05";
}
