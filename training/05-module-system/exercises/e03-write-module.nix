# Exercise 03: Writing a Complete Module
# Run: nix eval -f training/05-module-system/exercises/e03-write-module.nix
#
# Write a "dev environment" module from scratch.

let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;

  # ── Exercise: Dev Environment Module ──────────────────────────────────
  #
  # TODO: Write a module that configures a development environment.
  #
  # Options to declare (under options.dev):
  #   enable        - mkEnableOption "development environment"
  #   language      - enum [ "python" "go" "rust" ], no default (required when enabled)
  #   editor        - str, default "nvim"
  #   extraPackages - listOf str, default []
  #
  # Config to set when enabled:
  #   dev.packages  - a list computed from the language choice + extraPackages:
  #     python → [ "python3" "pip" ] ++ extraPackages
  #     go     → [ "go" "gopls" ] ++ extraPackages
  #     rust   → [ "rustc" "cargo" ] ++ extraPackages
  #   dev.envFile   - a string with the content:
  #     "EDITOR=<editor>\nLANG=<language>\n"

  devModule =
    { config, lib, ... }:
    let
      cfg = config.dev;
    in
    {
      options.dev = {
        enable = lib.mkEnableOption "development environment";

        language = lib.mkOption {
          type = lib.types.enum [
            "python"
            "go"
            "rust"
          ];
          description = "Primary development language.";
        };

        editor = lib.mkOption {
          type = lib.types.str;
          default = "nvim";
        };

        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        # These are "output" options — set by the module itself:
        packages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Computed list of packages.";
        };

        envFile = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Generated environment file content.";
        };
      };

      # TODO: Implement the config block
      # HINT:
      # config = lib.mkIf cfg.enable {
      #   dev.packages = (langPackages) ++ cfg.extraPackages;
      #   dev.envFile = "EDITOR=${cfg.editor}\nLANG=${cfg.language}\n";
      # };
      #
      # where langPackages depends on cfg.language:
      #   use if/else or a lookup attrset
      config = lib.mkIf cfg.enable {
        # TODO: Fill in the config
      };
    };

  # ── Test cases ────────────────────────────────────────────────────────

  testPython = lib.evalModules {
    modules = [
      devModule
      {
        config.dev.enable = true;
        config.dev.language = "python";
        config.dev.extraPackages = [ "black" ];
      }
    ];
  };

  testGo = lib.evalModules {
    modules = [
      devModule
      {
        config.dev.enable = true;
        config.dev.language = "go";
        config.dev.editor = "code";
      }
    ];
  };

  testDisabled = lib.evalModules {
    modules = [
      devModule
      # dev.enable defaults to false
      # Need to set language since it has no default, but it won't be used
      { config.dev.language = "python"; }
    ];
  };

in
{
  python_packages =
    testPython.config.dev.packages == [
      "python3"
      "pip"
      "black"
    ];
  python_env = testPython.config.dev.envFile == "EDITOR=nvim\nLANG=python\n";

  go_packages =
    testGo.config.dev.packages == [
      "go"
      "gopls"
    ];
  go_env = testGo.config.dev.envFile == "EDITOR=code\nLANG=go\n";

  disabled_packages = testDisabled.config.dev.packages == [ ];
  disabled_env = testDisabled.config.dev.envFile == "";
}
