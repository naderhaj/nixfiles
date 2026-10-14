# Exercise 04: let, with, and inherit
# Run: nix eval -f training/01-language/exercises/e04-let-with-inherit.nix
#
# Replace `null` with the correct answers.

let
  # ── Exercise 1: Scoping rules ─────────────────────────────────────────

  # TODO: What does this evaluate to? (let vs with precedence)
  scope_test_1 = null;
  # The expression:  let a = 10; in with { a = 1; }; a
  # EXPECTED: 10  (let always wins over with)

  # TODO: What does this evaluate to? (nested with)
  scope_test_2 = null;
  # The expression:  with { a = 1; }; with { a = 2; }; a
  # EXPECTED: 2  (inner with wins)

  # TODO: What does this evaluate to?
  scope_test_3 = null;
  # The expression:
  #   let x = 1;
  #   in let x = 2;
  #      in x
  # EXPECTED: 2  (inner let shadows outer let)

  # ── Exercise 2: Rewrite without `with` ────────────────────────────────

  pkgs = {
    git = "git-pkg";
    ripgrep = "rg-pkg";
    fd = "fd-pkg";
    bat = "bat-pkg";
  };

  # This uses `with`:
  # packages_with = with pkgs; [ git ripgrep fd ];

  # TODO: Rewrite the above WITHOUT using `with`
  packages_explicit = null;
  # EXPECTED: [ "git-pkg" "rg-pkg" "fd-pkg" ]

  # ── Exercise 3: inherit ───────────────────────────────────────────────

  name = "training";
  version = "1.0";

  # TODO: Use `inherit` to create { name = name; version = version; type = "course"; }
  meta = null;
  # EXPECTED: { name = "training"; type = "course"; version = "1.0"; }
  # HINT: { inherit name version; type = "course"; }

  # ── Exercise 4: inherit from ──────────────────────────────────────────

  config = {
    host = "localhost";
    port = 8080;
    debug = true;
  };

  # TODO: Use `inherit (config)` to create { host = config.host; port = config.port; }
  connection = null;
  # EXPECTED: { host = "localhost"; port = 8080; }
  # HINT: { inherit (config) host port; }

  # ── Exercise 5: Scoping puzzle ────────────────────────────────────────

  # What does this complex scoping example evaluate to?
  # Think carefully about the resolution order!
  puzzle =
    let
      x = 1;
      y = 2;
      s = {
        x = 10;
        y = 20;
        z = 30;
      };
    in
    with s;
    x + y + z;

  # TODO: What is the value of `puzzle`?
  puzzle_answer = null;
  # EXPECTED: 33  (x=1 from let, y=2 from let, z=30 from with)
  # let bindings (x=1, y=2) shadow the `with s` bindings (x=10, y=20)
  # but z=30 comes from `with s` since there's no `let z`

in
{
  ex1_scoping = scope_test_1 == 10 && scope_test_2 == 2 && scope_test_3 == 2;

  ex2_no_with =
    packages_explicit == [
      "git-pkg"
      "rg-pkg"
      "fd-pkg"
    ];

  ex3_inherit =
    meta == {
      name = "training";
      type = "course";
      version = "1.0";
    };

  ex4_inherit_from =
    connection == {
      host = "localhost";
      port = 8080;
    };

  ex5_puzzle = puzzle_answer == 33;
}
