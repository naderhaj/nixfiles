# Exercise 05: Paths and Imports
# Run: nix eval -f training/01-language/exercises/e05-paths-imports.nix
#
# This exercise explores path behavior and imports.

let
  # ── Exercise 1: Path vs string ────────────────────────────────────────

  # TODO: What type is "/tmp/foo"? (the string with quotes)
  type_of_string_path = "string";
  # EXPECTED: "string"

  # TODO: What type is /tmp/foo? (the path literal)
  # HINT: builtins.typeOf /tmp/foo
  type_of_path_literal = "path";
  # EXPECTED: "path"

  # ── Exercise 2: Import a file ─────────────────────────────────────────

  # The file `helper.nix` in this directory exports a function.
  # TODO: Import it and call it with the argument 5
  helper_result = import ./helper.nix 5;
  # EXPECTED: 25
  # HINT: (import ./helper.nix) 5

  # ── Exercise 3: Import an attrset ─────────────────────────────────────

  # The file `data.nix` in this directory exports an attrset.
  # TODO: Import it and access the `greeting` key
  greeting = (import ./data.nix).greeting;
  # EXPECTED: "hello from data.nix"

  # ── Exercise 4: readDir ───────────────────────────────────────────────

  # TODO: Use builtins.readDir to check what type "helper.nix" is in this directory
  # Read this exercises directory and get the type of "helper.nix"
  helper_type = (builtins.readDir ./.)."helper.nix";
  # EXPECTED: "regular"
  # HINT: (builtins.readDir ./.).helper_nix won't work — the key is "helper.nix"
  #       Use: (builtins.readDir ./.)."helper.nix"

  # ── Exercise 5: Path concatenation ───────────────────────────────────

  base = /tmp;

  # TODO: Produce the path /tmp/logs/app.log using path concatenation
  log_path = base + "/logs/app.log";
  # EXPECTED: /tmp/logs/app.log
  # HINT: base + "/logs/app.log"

  # TODO: What type is the result of: "/tmp" + "/foo"  (string + string)
  string_concat_type = "string";
  # EXPECTED: "string"

in
{
  ex1_types = type_of_string_path == "string" && type_of_path_literal == "path";

  ex2_import_func = helper_result == 25;

  ex3_import_set = greeting == "hello from data.nix";

  ex4_readdir = helper_type == "regular";

  ex5_paths = log_path == /tmp/logs/app.log && string_concat_type == "string";
}
