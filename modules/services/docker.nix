{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.os.docker;
in
{
  options.os.docker.enable = lib.mkEnableOption "rootless Docker";

  config = lib.mkIf cfg.enable {
    users.users.${config.os.user.name}.linger = true;

    virtualisation.docker.rootless = {
      enable = true;
      daemon.settings.log-driver = "local";
      setSocketVariable = true;
    };

    os.packages = [ pkgs.docker-compose ];
  };
}
