# Exercise 02: Module Anatomy
# Run: nix eval -f training/05-module-system/exercises/e02-module-anatomy.nix
#
# Explore module structure and the config/options split.

let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;

  # ── Exercise 1: Implicit vs explicit config ───────────────────────────
  #
  # These two modules are equivalent. Verify by evaluating both.

  moduleImplicit = { lib, ... }: {
    # No `options` key → everything is config
    my.setting = "value";
  };

  moduleExplicit = { lib, ... }: {
    config = {
      my.setting = "value";
    };
  };

  # Both work with evalModules:
  testImplicit = lib.evalModules {
    modules = [
      { options.my.setting = lib.mkOption { type = lib.types.str; }; }
      moduleImplicit
    ];
  };

  testExplicit = lib.evalModules {
    modules = [
      { options.my.setting = lib.mkOption { type = lib.types.str; }; }
      moduleExplicit
    ];
  };

  # TODO: Are the results the same?
  implicit_value = null;
  explicit_value = null;
  # EXPECTED: both "value"

  # ── Exercise 2: Module with enable pattern ────────────────────────────
  #
  # TODO: Write a module that:
  # - Declares options.services.greeter.enable (mkEnableOption)
  # - Declares options.services.greeter.name (str, default "World")
  # - When enabled, sets options.services.greeter.message to "Hello, {name}!"

  greeterModule =
    { config, lib, ... }:
    let
      cfg = config.services.greeter;
    in
    {
      options.services.greeter = {
        enable = lib.mkEnableOption "greeter service";
        name = lib.mkOption {
          type = lib.types.str;
          default = "World";
        };
        message = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      # TODO: Use mkIf to set message only when enabled
      config = lib.mkIf cfg.enable {
        # TODO: set services.greeter.message
      };
    };

  testGreeterEnabled = lib.evalModules {
    modules = [
      greeterModule
      {
        config.services.greeter.enable = true;
        config.services.greeter.name = "Nader";
      }
    ];
  };

  testGreeterDisabled = lib.evalModules {
    modules = [
      greeterModule
      # enable defaults to false
    ];
  };

  greeter_enabled_msg = null;
  # EXPECTED: "Hello, Nader!"

  greeter_disabled_msg = null;
  # EXPECTED: ""

  # ── Exercise 3: Inter-module communication ────────────────────────────
  #
  # Two modules reading each other's config:

  moduleA = { lib, ... }: {
    options.server.port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
  };

  moduleB = { config, lib, ... }: {
    options.client.serverUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:${toString config.server.port}";
    };
  };

  testInterModule = lib.evalModules {
    modules = [
      moduleA
      moduleB
    ];
  };

  # TODO: What is client.serverUrl when server.port is default (8080)?
  server_url = null;
  # EXPECTED: "http://localhost:8080"

  # TODO: What if we override the port?
  testInterModule2 = lib.evalModules {
    modules = [
      moduleA
      moduleB
      { config.server.port = 3000; }
    ];
  };

  server_url_custom = null;
  # EXPECTED: "http://localhost:3000"

in
{
  ex1_implicit_explicit = implicit_value == "value" && explicit_value == "value";

  ex2_greeter = greeter_enabled_msg == "Hello, Nader!" && greeter_disabled_msg == "";

  ex3_inter_module =
    server_url == "http://localhost:8080" && server_url_custom == "http://localhost:3000";
}
