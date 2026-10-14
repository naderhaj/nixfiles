# Exercise 01: Fixed Points
# Run: nix eval -f training/07-advanced/exercises/e01-fixed-point.nix
#
# Implement fix and understand how overlays work at the deepest level.

let
  # ── Exercise 1: Implement fix ─────────────────────────────────────────

  # TODO: Implement the fixed-point combinator
  # fix = f: let x = f x; in x;
  fix = null;
  # HINT: fix = f: let x = f x; in x;

  # Test it:
  # result1 = fix (self: { a = 1; b = self.a + 1; })
  # EXPECTED: { a = 1; b = 2; }

  # ── Exercise 2: Self-referential package set ──────────────────────────

  # TODO: Use fix to create a "package set" where packages reference each other
  # Define: base = "1.0", lib depends on base, app depends on lib
  pkgSet = null;
  # HINT:
  # pkgSet = fix (self: {
  #   base = { name = "base"; version = "1.0"; };
  #   myLib = { name = "mylib"; dep = self.base; };
  #   myApp = { name = "myapp"; dep = self.myLib; };
  # });
  # EXPECTED: pkgSet.myApp.dep.dep.version == "1.0"

  # ── Exercise 3: Manual overlay application ────────────────────────────

  # Base package set as a function (like nixpkgs internally):
  baseF = self: {
    greeting = "hello";
    target = "world";
    message = "${self.greeting}, ${self.target}!";
  };

  # An overlay that changes the target:
  overlay1 = final: prev: {
    target = "Nix";
  };

  # TODO: Apply the overlay manually using fix
  # The pattern: fix (self: let base = baseF self; in base // overlay1 self base)
  result_with_overlay = null;
  # EXPECTED: { greeting = "hello"; message = "hello, Nix!"; target = "Nix"; }

  # ── Exercise 4: Two overlays ──────────────────────────────────────────

  overlay2 = final: prev: {
    greeting = "Bonjour";
  };

  # TODO: Apply BOTH overlays
  # HINT: fix (self:
  #   let
  #     base = baseF self;
  #     after1 = base // overlay1 self base;
  #     after2 = after1 // overlay2 self after1;
  #   in after2
  # )
  result_two_overlays = null;
  # EXPECTED: { greeting = "Bonjour"; message = "Bonjour, Nix!"; target = "Nix"; }

  # ── Exercise 5: Generic overlay applier ───────────────────────────────

  # TODO: Write a function that takes a base function and a list of overlays
  # and returns the fixed-point result
  applyOverlays = null;
  # HINT:
  # applyOverlays = baseF: overlays:
  #   fix (self:
  #     builtins.foldl'
  #       (prev: overlay: prev // overlay self prev)
  #       (baseF self)
  #       overlays
  #   );

  result_generic = null;
  # Use: applyOverlays baseF [ overlay1 overlay2 ]
  # EXPECTED: { greeting = "Bonjour"; message = "Bonjour, Nix!"; target = "Nix"; }

  # ── Exercise 6: Why final vs prev matters ─────────────────────────────

  # This overlay is WRONG — it would cause infinite recursion:
  # bad_overlay = final: prev: {
  #   greeting = final.greeting + "!";  # BOOM — greeting depends on itself
  # };

  # This overlay is CORRECT:
  good_overlay = final: prev: {
    greeting = prev.greeting + "!"; # Uses the PREVIOUS value
  };

  result_good = null;
  # Use: applyOverlays baseF [ good_overlay ]
  # EXPECTED: { greeting = "hello!"; message = "hello!, world!"; target = "world"; }

  # Helper for verification (only used if fix is implemented):
  _fix =
    f:
    let
      x = f x;
    in
    x;
  _applyOverlays =
    bF: ovs: _fix (self: builtins.foldl' (prev: overlay: prev // overlay self prev) (bF self) ovs);
  _r1 = _fix (self: {
    a = 1;
    b = self.a + 1;
  });
  _pkgSet = _fix (self: {
    base = {
      name = "base";
      version = "1.0";
    };
    myLib = {
      name = "mylib";
      dep = self.base;
    };
    myApp = {
      name = "myapp";
      dep = self.myLib;
    };
  });
  _r_ov = _fix (
    self:
    let
      base = baseF self;
    in
    base // overlay1 self base
  );
  _r_2ov = _applyOverlays baseF [
    overlay1
    overlay2
  ];
  _r_good = _applyOverlays baseF [ good_overlay ];

in
{
  # Use reference implementations for verification:
  ex1_fix =
    _r1 == {
      a = 1;
      b = 2;
    };
  ex2_pkgset = _pkgSet.myApp.dep.dep.version == "1.0";
  ex3_overlay =
    _r_ov == {
      greeting = "hello";
      message = "hello, Nix!";
      target = "Nix";
    };
  ex4_two =
    _r_2ov == {
      greeting = "Bonjour";
      message = "Bonjour, Nix!";
      target = "Nix";
    };
  ex5_generic =
    _r_2ov == {
      greeting = "Bonjour";
      message = "Bonjour, Nix!";
      target = "Nix";
    };
  ex6_good_overlay =
    _r_good == {
      greeting = "hello!";
      message = "hello!, world!";
      target = "world";
    };

  # TODO: Uncomment these once you implement fix and applyOverlays:
  # ex1_yours = (fix (self: { a = 1; b = self.a + 1; })) == { a = 1; b = 2; };
  # ex3_yours = result_with_overlay.message == "hello, Nix!";
  # ex5_yours = result_generic.message == "Bonjour, Nix!";
}
