# Exercise 04: The Type System
# Run: nix eval -f training/05-module-system/exercises/e04-types.nix
#
# Explore different types and their merging behavior.

let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;

  # ── Exercise 1: Scalar types don't merge ──────────────────────────────
  #
  # Two modules set the same string option. This would normally error,
  # but we use mkDefault to resolve it.

  result1 = lib.evalModules {
    modules = [
      { options.name = lib.mkOption { type = lib.types.str; }; }
      { config.name = lib.mkDefault "from-module-A"; }
      { config.name = "from-module-B"; }
    ];
  };

  # TODO: Which value wins?
  name_winner = null;
  # EXPECTED: "from-module-B"  (normal priority beats mkDefault)

  # ── Exercise 2: List types concatenate ────────────────────────────────

  result2 = lib.evalModules {
    modules = [
      {
        options.tags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      }
      {
        config.tags = [
          "web"
          "api"
        ];
      }
      { config.tags = [ "production" ]; }
      { config.tags = [ "monitored" ]; }
    ];
  };

  # TODO: What is the merged list?
  merged_tags = null;
  # EXPECTED: [ "web" "api" "production" "monitored" ]

  # ── Exercise 3: attrsOf deep merges ───────────────────────────────────

  result3 = lib.evalModules {
    modules = [
      {
        options.settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
        };
      }
      {
        config.settings = {
          host = "localhost";
          port = "8080";
        };
      }
      {
        config.settings = {
          port = "3000";
          debug = "true";
        };
      }
    ];
  };

  # TODO: What is the merged attrset?
  # HINT: attrsOf merges keys, but individual values (str) conflict if set twice
  # Wait — port is set twice! This will actually error because str can't merge.
  # Let's use mkDefault:

  result3_fixed = lib.evalModules {
    modules = [
      {
        options.settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
        };
      }
      {
        config.settings = {
          host = "localhost";
          port = lib.mkDefault "8080";
        };
      }
      {
        config.settings = {
          port = "3000";
          debug = "true";
        };
      }
    ];
  };

  merged_settings = null;
  # EXPECTED: { debug = "true"; host = "localhost"; port = "3000"; }

  # ── Exercise 4: Enum type ────────────────────────────────────────────

  result4 = lib.evalModules {
    modules = [
      {
        options.theme = lib.mkOption {
          type = lib.types.enum [
            "light"
            "dark"
            "auto"
          ];
          default = "auto";
        };
      }
      { config.theme = "dark"; }
    ];
  };

  # TODO: What is the theme?
  theme_value = null;
  # EXPECTED: "dark"

  # ── Exercise 5: Submodule type ────────────────────────────────────────

  result5 = lib.evalModules {
    modules = [
      {
        options.database = lib.mkOption {
          type = lib.types.submodule {
            options = {
              host = lib.mkOption {
                type = lib.types.str;
                default = "localhost";
              };
              port = lib.mkOption {
                type = lib.types.port;
                default = 5432;
              };
              name = lib.mkOption { type = lib.types.str; };
            };
          };
        };
      }
      {
        config.database = {
          name = "myapp";
          port = 3306;
        };
      }
    ];
  };

  # TODO: What are the database values? (defaults apply for unset options)
  db_host = null;
  db_port = null;
  db_name = null;
  # EXPECTED: "localhost", 3306, "myapp"

  # ── Exercise 6: nullOr type ──────────────────────────────────────────

  result6 = lib.evalModules {
    modules = [
      {
        options.optionalValue = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      }
      # Don't set any value — default (null) should apply
    ];
  };

  result6_set = lib.evalModules {
    modules = [
      {
        options.optionalValue = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      }
      { config.optionalValue = "present"; }
    ];
  };

  # TODO: What are the values?
  null_value = null; # What is result6.config.optionalValue?
  present_value = null; # What is result6_set.config.optionalValue?
  # EXPECTED: null and "present"
  # HINT: nullOr allows a value to be either null or the inner type

in
{
  ex1_priority = name_winner == "from-module-B";
  ex2_lists =
    merged_tags == [
      "web"
      "api"
      "production"
      "monitored"
    ];
  ex3_attrs =
    merged_settings == {
      debug = "true";
      host = "localhost";
      port = "3000";
    };
  ex4_enum = theme_value == "dark";
  ex5_submodule = db_host == "localhost" && db_port == 3306 && db_name == "myapp";
  ex6_nullor = null_value == null && present_value == "present";
}
