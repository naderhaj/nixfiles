# Exercise 01: Options and Config with evalModules
# Run: nix eval -f training/05-module-system/exercises/e01-options-config.nix
#
# This exercise uses lib.evalModules to explore the module system in isolation.

let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;

  # ── Exercise 1: Basic evalModules ─────────────────────────────────────
  #
  # evalModules takes a list of modules, merges them, and returns the result.

  result1 = lib.evalModules {
    modules = [
      # Module 1: declare an option
      {
        options.greeting = lib.mkOption {
          type = lib.types.str;
          description = "A greeting message";
        };
      }

      # Module 2: set the option's value
      {
        config.greeting = "Hello from evalModules!";
      }
    ];
  };

  # TODO: What is result1.config.greeting?
  greeting_value = null;
  # EXPECTED: "Hello from evalModules!"

  # ── Exercise 2: Default values ────────────────────────────────────────

  result2 = lib.evalModules {
    modules = [
      {
        options.name = lib.mkOption {
          type = lib.types.str;
          default = "default-name";
        };
        options.enabled = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      }
      # No config module — defaults should apply
    ];
  };

  # TODO: What are the values?
  default_name = null;
  # EXPECTED: "default-name"

  default_enabled = null;
  # EXPECTED: true

  # ── Exercise 3: mkDefault vs normal priority ─────────────────────────

  result3 = lib.evalModules {
    modules = [
      {
        options.port = lib.mkOption {
          type = lib.types.port;
        };
      }
      # Module A: sets a default
      { config.port = lib.mkDefault 8080; }
      # Module B: sets a normal value
      { config.port = 3000; }
    ];
  };

  # TODO: Which value wins? mkDefault (8080) or normal (3000)?
  port_value = null;
  # EXPECTED: 3000  (normal priority 1000 beats mkDefault priority 1500)

  # ── Exercise 4: List merging ──────────────────────────────────────────

  result4 = lib.evalModules {
    modules = [
      {
        options.items = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      }
      {
        config.items = [
          "alpha"
          "beta"
        ];
      }
      { config.items = [ "gamma" ]; }
    ];
  };

  # TODO: What is the merged list?
  merged_items = null;
  # EXPECTED: [ "alpha" "beta" "gamma" ]  (lists concatenate!)

  # ── Exercise 5: mkIf ─────────────────────────────────────────────────

  result5 = lib.evalModules {
    modules = [
      {
        options.feature.enable = lib.mkEnableOption "my feature";
        options.feature.message = lib.mkOption {
          type = lib.types.str;
          default = "not set";
        };
      }
      {
        config.feature.enable = false;
      }
      ({ config, lib, ... }: {
        config = lib.mkIf config.feature.enable {
          feature.message = "feature is on!";
        };
      })
    ];
  };

  # TODO: feature.enable is false, so what is feature.message?
  feature_message = null;
  # EXPECTED: "not set"  (mkIf prevents the message from being set)

  # ── Exercise 6: Write your own option + config ────────────────────────
  #
  # TODO: Create a result6 using evalModules that:
  # 1. Declares options: app.name (str), app.version (str), app.debug (bool, default false)
  # 2. Sets config: app.name = "training", app.version = "1.0"
  # 3. Verify result6.config.app.name == "training"

  result6 = lib.evalModules {
    modules = [
      # TODO: Write your modules here
      {
        options.app = {
          name = lib.mkOption { type = lib.types.str; };
          version = lib.mkOption { type = lib.types.str; };
          debug = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      }
      {
        # TODO: Set the config values
      }
    ];
  };

  app_name = null;
  # EXPECTED: "training"

in
{
  ex1_basic = greeting_value == "Hello from evalModules!";
  ex2_defaults = default_name == "default-name" && default_enabled == true;
  ex3_priority = port_value == 3000;
  ex4_lists =
    merged_items == [
      "alpha"
      "beta"
      "gamma"
    ];
  ex5_mkif = feature_message == "not set";
  ex6_custom = app_name == "training";
}
