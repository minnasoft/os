{ lib, pkgs }:

let
  eval =
    modules:
    lib.evalModules {
      modules = [
        {
          options = {
            users.users = lib.mkOption {
              type = lib.types.attrs;
              default = { };
            };

            system.stateVersion = lib.mkOption {
              type = lib.types.str;
              default = "26.05";
            };

            home-manager = {
              useGlobalPkgs = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };

              useUserPackages = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };

              users = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.submodule {
                    options.home = {
                      packages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                      };

                      stateVersion = lib.mkOption {
                        type = lib.types.str;
                      };
                    };
                  }
                );
                default = { };
              };
            };
          };
        }
        ../modules/os.nix
      ]
      ++ modules;
    };

  defaultConfig = (eval [ ]).config;
  defaults = defaultConfig.os;
  defaultUser = defaultConfig.users.users.${defaults.user.name};

  configured =
    (eval [
      {
        os = {
          user = {
            name = "madoka";
            password = "homura";
            extraGroups = [ "networkmanager" ];
          };

          packages = [ pkgs.hello ];
        };
      }
    ]).config;

  configuredUser = configured.users.users.${configured.os.user.name};
  configuredHome = configured.home-manager.users.${configured.os.user.name}.home;
in
assert lib.assertMsg (defaults.user.name == "os") "os.user.name should default to os";
assert lib.assertMsg (defaults.user.password == "os") "os.user.password should default to os";
assert lib.assertMsg (
  defaults.user.extraGroups == [ "wheel" ]
) "os.user.extraGroups should default to wheel";
assert lib.assertMsg (defaults.packages == [ ]) "os.packages should default to an empty list";
assert lib.assertMsg defaultUser.isNormalUser "os.user should create a normal user by default";
assert lib.assertMsg (
  defaultUser.initialPassword == "os"
) "os.user should set the configured initial password";
assert lib.assertMsg (
  defaultUser.extraGroups == [ "wheel" ]
) "os.user should set configured extra groups";
assert lib.assertMsg (configured.os.user.name == "madoka") "os.user.name should be configurable";
assert lib.assertMsg (
  configured.os.user.password == "homura"
) "os.user.password should be configurable";
assert lib.assertMsg (
  configured.os.user.extraGroups == [ "networkmanager" ]
) "os.user.extraGroups should be configurable";
assert lib.assertMsg (
  configured.os.packages == [ pkgs.hello ]
) "os.packages should be configurable";
assert lib.assertMsg configuredUser.isNormalUser
  "configured os.user should always create a normal user";
assert lib.assertMsg (
  configuredUser.initialPassword == "homura"
) "configured os.user password should update the NixOS user";
assert lib.assertMsg (
  configuredUser.extraGroups == [ "networkmanager" ]
) "configured os.user groups should update the NixOS user";
assert lib.assertMsg (
  configured.home-manager.useGlobalPkgs && configured.home-manager.useUserPackages
) "os should enable Home Manager with global pkgs and user packages";
assert lib.assertMsg (
  configuredHome.stateVersion == configured.system.stateVersion
) "os should derive Home Manager stateVersion from system.stateVersion";
assert lib.assertMsg (
  configuredHome.packages == [ pkgs.hello ]
) "os.packages should apply to the primary Home Manager user";
pkgs.runCommand "os-option-tests" { } ''
  touch $out
''
