{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.grub.enable = lib.mkDefault false;

  fileSystems."/" = {
    device = lib.mkDefault "/dev/disk/by-label/nixos";
    fsType = lib.mkDefault "ext4";
  };

  users.users.vereis = {
    isNormalUser = true;
    initialPassword = "vereis";
    extraGroups = [ "wheel" ];
  };

  virtualisation.vmVariant.virtualisation = {
    cores = 2;
    memorySize = 2048;
  };
}
