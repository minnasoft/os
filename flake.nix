{
  description = "A NixOS framework for defining tidy little systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks.flakeModule
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          treefmt = {
            projectRootFile = "flake.nix";

            programs = {
              nixfmt.enable = true;

              mdformat = {
                enable = true;
                settings.wrap = "no";
              };
            };
          };

          pre-commit.settings.hooks = {
            treefmt.enable = true;

            deadnix = {
              enable = true;
              settings = {
                edit = false;
                noUnderscore = false;
              };
            };

            statix = {
              enable = true;
              settings.format = "stderr";
            };

            convco.enable = true;
          };

          devShells.default = pkgs.mkShell {
            packages = [
              config.treefmt.build.wrapper
              pkgs.convco
              pkgs.deadnix
              pkgs.statix
            ];
          };
        };
    };
}
