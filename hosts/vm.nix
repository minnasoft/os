{
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.grub.enable = lib.mkDefault false;

  os = {
    docker.enable = true;
    tailscale.enable = true;

    packages = [ pkgs.cowsay ];
  };

  fileSystems."/" = {
    device = lib.mkDefault "/dev/disk/by-label/nixos";
    fsType = lib.mkDefault "ext4";
  };

  virtualisation.vmVariant.virtualisation = {
    cores = 2;
    memorySize = 2048;
  };
}
