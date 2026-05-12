{
  config,
  lib,
  ...
}:

{
  options.os.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf config.os.tailscale.enable {
    services.tailscale.enable = true;

    # TODO: Set the primary user as Tailscale operator once auth keys and secrets exist.

    networking.firewall = {
      allowedUDPPorts = [ config.services.tailscale.port ];
      interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts =
        lib.mkIf config.os.ssh.enable
          [ 22 ];
    };
  };
}
