{ config, lib, ... }:

{
  options.os.ssh.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable OpenSSH with password and root login disabled.";
  };

  config = lib.mkIf config.os.ssh.enable {
    services.fail2ban.enable = true;

    services.openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        AllowUsers = [ config.os.user.name ];
        KbdInteractiveAuthentication = false;
        MaxAuthTries = 3;
        PasswordAuthentication = false;
        PermitEmptyPasswords = false;
        PermitRootLogin = "no";
        X11Forwarding = true;
      };
    };
  };
}
