{ lib, pkgs }:

let
  eval =
    modules:
    lib.evalModules {
      specialArgs = { inherit pkgs; };

      modules = [
        {
          options = {
            os.packages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
            };

            os.user.name = lib.mkOption {
              type = lib.types.nonEmptyStr;
              default = "os";
            };

            users.users = lib.mkOption {
              type = lib.types.attrsOf (
                lib.types.submodule {
                  options.linger = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                  };
                }
              );
              default = { };
            };

            networking.firewall = {
              allowedUDPPorts = lib.mkOption {
                type = lib.types.listOf lib.types.port;
                default = [ ];
              };

              interfaces = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.submodule {
                    options.allowedTCPPorts = lib.mkOption {
                      type = lib.types.listOf lib.types.port;
                      default = [ ];
                    };
                  }
                );
                default = { };
              };
            };

            services = {
              fail2ban.enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };

              openssh = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };

                openFirewall = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                };

                settings = lib.mkOption {
                  type = lib.types.attrs;
                  default = { };
                };
              };

              tailscale = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };

                interfaceName = lib.mkOption {
                  type = lib.types.str;
                  default = "tailscale0";
                };

                port = lib.mkOption {
                  type = lib.types.port;
                  default = 41641;
                };
              };
            };

            virtualisation.docker = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };

              rootless = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };

                daemon.settings = lib.mkOption {
                  type = lib.types.attrs;
                  default = { };
                };

                setSocketVariable = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };
              };
            };
          };
        }
        ../modules/services/docker.nix
        ../modules/services/ssh.nix
        ../modules/services/tailscale.nix
      ]
      ++ modules;
    };

  defaults = (eval [ ]).config;

  enabled =
    (eval [
      {
        os = {
          docker.enable = true;
          ssh.enable = true;
          tailscale.enable = true;
        };
      }
    ]).config;

  tailscaleWithoutSsh =
    (eval [
      {
        os = {
          ssh.enable = false;
          tailscale.enable = true;
        };

        services.tailscale.interfaceName = "tailnet0";
      }
    ]).config;
in
assert lib.assertMsg defaults.os.ssh.enable "os.ssh.enable should default to true";
assert lib.assertMsg (!defaults.os.tailscale.enable) "os.tailscale.enable should default to false";
assert lib.assertMsg (!defaults.os.docker.enable) "os.docker.enable should default to false";
assert lib.assertMsg defaults.services.openssh.enable "os.ssh should enable OpenSSH by default";
assert lib.assertMsg defaults.services.fail2ban.enable "os.ssh should enable fail2ban by default";
assert lib.assertMsg (
  !defaults.services.openssh.openFirewall
) "os.ssh should not globally open SSH";
assert lib.assertMsg (
  defaults.services.openssh.settings.AllowUsers == [ defaults.os.user.name ]
) "os.ssh should only allow the primary os user";
assert lib.assertMsg (
  !defaults.services.openssh.settings.PasswordAuthentication
) "os.ssh should disable password authentication";
assert lib.assertMsg (
  !defaults.services.openssh.settings.KbdInteractiveAuthentication
) "os.ssh should disable keyboard-interactive authentication";
assert lib.assertMsg (
  defaults.services.openssh.settings.MaxAuthTries == 3
) "os.ssh should limit authentication attempts";
assert lib.assertMsg (
  !defaults.services.openssh.settings.PermitEmptyPasswords
) "os.ssh should reject empty passwords";
assert lib.assertMsg (
  defaults.services.openssh.settings.PermitRootLogin == "no"
) "os.ssh should disable root login";
assert lib.assertMsg defaults.services.openssh.settings.X11Forwarding
  "os.ssh should enable X11 forwarding";
assert lib.assertMsg enabled.services.tailscale.enable "os.tailscale should enable Tailscale";
assert lib.assertMsg (
  enabled.networking.firewall.interfaces.${enabled.services.tailscale.interfaceName}.allowedTCPPorts
  == [ 22 ]
) "os.tailscale should open SSH only on the configured Tailscale interface";
assert lib.assertMsg (
  enabled.networking.firewall.allowedUDPPorts == [ enabled.services.tailscale.port ]
) "os.tailscale should open the Tailscale UDP port";
assert lib.assertMsg (
  tailscaleWithoutSsh.networking.firewall.interfaces.tailnet0.allowedTCPPorts == [ ]
) "os.tailscale should not open SSH on the tailnet interface when SSH is disabled";
assert lib.assertMsg tailscaleWithoutSsh.services.tailscale.enable
  "os.tailscale should not require os.ssh";
assert lib.assertMsg (
  !enabled.virtualisation.docker.enable
) "os.docker should not enable rootful Docker";
assert lib.assertMsg enabled.virtualisation.docker.rootless.enable
  "os.docker should enable rootless Docker";
assert lib.assertMsg enabled.virtualisation.docker.rootless.setSocketVariable
  "os.docker should set the Docker socket variable";
assert lib.assertMsg (
  enabled.virtualisation.docker.rootless.daemon.settings.log-driver == "local"
) "os.docker should use Docker's rotating local log driver";
assert lib.assertMsg enabled.users.users.os.linger
  "os.docker should enable linger for rootless Docker";
assert lib.assertMsg (
  enabled.os.packages == [ pkgs.docker-compose ]
) "os.docker should add Docker Compose to os.packages";
pkgs.runCommand "service-option-tests" { } ''
  touch $out
''
