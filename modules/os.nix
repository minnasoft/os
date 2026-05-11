{ config, lib, ... }:

{
  options.os = {
    user = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "os";
        description = "Primary user name for host-level configuration.";
      };

      # TODO: Default to null or require hosts to set this before real migrations.
      password = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "os";
        description = "Initial password for the primary os user.";
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "wheel" ];
        description = "Extra groups assigned to the primary os user.";
      };
    };
  };

  config.users.users.${config.os.user.name} = {
    inherit (config.os.user) extraGroups;
    isNormalUser = true;
  }
  // lib.optionalAttrs (config.os.user.password != null) {
    initialPassword = config.os.user.password;
  };
}
