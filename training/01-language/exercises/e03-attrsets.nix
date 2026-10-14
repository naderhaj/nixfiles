# Exercise 03: Attribute Sets
# Run: nix eval -f training/01-language/exercises/e03-attrsets.nix
#
# Replace `null` with correct values or expressions.

let
  # ── Exercise 1: The // operator ───────────────────────────────────────

  base = {
    name = "myapp";
    version = "1.0";
    debug = false;
  };

  # TODO: Use // to update `base` with version "2.0" and debug true
  updated = base // {
    version = "2.0";
    debug = true;
  };
  # EXPECTED: { debug = true; name = "myapp"; version = "2.0"; }

  # ── Exercise 2: Shallow merge trap ────────────────────────────────────

  server = {
    hostname = "zeus";
    config = {
      port = 80;
      ssl = true;
    };
  };

  # TODO: What does this produce? Write the exact result.
  # server // { config = { port = 443; }; }
  merge_result = {
    hostname = "zeus";
    config = {
      port = 443;
    };
  };
  # EXPECTED: { config = { port = 443; }; hostname = "zeus"; }
  # NOTE: ssl is GONE because // is shallow — it replaced the entire config attrset

  # ── Exercise 3: The ? operator ────────────────────────────────────────

  settings = {
    color = "blue";
    size = 42;
  };

  # TODO: Check if `settings` has a "color" attribute
  has_color = settings ? color;
  # EXPECTED: true

  # TODO: Get settings.theme, defaulting to "dark" if it doesn't exist
  theme = settings.theme or "dark";
  # EXPECTED: "dark"
  # HINT: settings.theme or "dark"

  # ── Exercise 4: mapAttrs ──────────────────────────────────────────────

  scores = {
    alice = 85;
    bob = 92;
    carol = 78;
  };

  # TODO: Use builtins.mapAttrs to add 10 to every score
  curved = builtins.mapAttrs (name: score: score + 10) scores;
  # EXPECTED: { alice = 95; bob = 102; carol = 88; }
  # HINT: builtins.mapAttrs (name: score: ???) scores

  # ── Exercise 5: Build an attrset from a list ──────────────────────────

  names = [
    "alpha"
    "beta"
    "gamma"
  ];

  # TODO: Build { alpha = 1; beta = 2; gamma = 3; } from the names list
  # Give each name its 1-based index
  indexed =
    let
      names = [
        "alpha"
        "beta"
        "gamma"
      ];

      indexed = builtins.listToAttrs (
        builtins.genList (i: {
          name = builtins.elemAt names i;
          value = i + 1;
        }) (builtins.length names)
      );
    in
    indexed;
  # EXPECTED: { alpha = 1; beta = 2; gamma = 3; }
  # HINT: Use builtins.listToAttrs with builtins.genList or a manual list of { name, value } pairs

  # ── Exercise 6: attrNames and attrValues ──────────────────────────────

  data = {
    z = 3;
    a = 1;
    m = 2;
  };

  # TODO: What does builtins.attrNames data return? (remember: sorted!)
  names_of_data = [
    "a"
    "m"
    "z"
  ];
  # EXPECTED: [ "a" "m" "z" ]

  # TODO: What does builtins.attrValues data return?
  # HINT: values are returned in the same order as attrNames (alphabetical by key)
  values_of_data = [
    1
    2
    3
  ];
  # EXPECTED: [ 1 2 3 ]

  # ── Exercise 7: removeAttrs ───────────────────────────────────────────

  record = {
    name = "test";
    password = "secret";
    role = "admin";
  };

  # TODO: Remove the "password" field
  safe_record = builtins.removeAttrs record [ "password" ];
  # EXPECTED: { name = "test"; role = "admin"; }

in
{
  ex1_update =
    updated == {
      debug = true;
      name = "myapp";
      version = "2.0";
    };
  ex2_shallow =
    merge_result == {
      config = {
        port = 443;
      };
      hostname = "zeus";
    };
  ex3_has_or = has_color == true && theme == "dark";
  ex4_map =
    curved == {
      alice = 95;
      bob = 102;
      carol = 88;
    };
  ex5_from_list =
    indexed == {
      alpha = 1;
      beta = 2;
      gamma = 3;
    };
  ex6_names_values =
    names_of_data == [
      "a"
      "m"
      "z"
    ]
    &&
      values_of_data == [
        1
        2
        3
      ];
  ex7_remove =
    safe_record == {
      name = "test";
      role = "admin";
    };
}
