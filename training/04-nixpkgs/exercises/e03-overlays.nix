# Exercise 03: Overlays and Overrides
# Run: nix eval -f training/04-nixpkgs/exercises/e03-overlays.nix
#
# This exercise explores overlay mechanics using a simplified package set.

let
  # A simplified "base package set" (simulating nixpkgs):
  basePkgs = {
    hello = {
      pname = "hello";
      version = "2.12";
      deps = [ ];
    };
    openssl = {
      pname = "openssl";
      version = "3.0";
      deps = [ ];
    };
    curl = {
      pname = "curl";
      version = "8.0";
      deps = [ basePkgs.openssl ];
    };
  };

  # A simple function to apply overlays (simplified version of nixpkgs' logic):
  applyOverlay =
    pkgs: overlay:
    let
      result = pkgs // overlay result pkgs;
    in
    result;

  # ── Exercise 1: Add a package via overlay ─────────────────────────────

  # TODO: Write an overlay that adds `myTool` to the package set
  overlay1 = final: prev: {
    # TODO: add myTool with pname "mytool", version "1.0", deps []
  };
  # EXPECTED: (applyOverlay basePkgs overlay1).myTool == { pname = "mytool"; version = "1.0"; deps = []; }

  pkgsWithOverlay1 = applyOverlay basePkgs overlay1;

  # ── Exercise 2: Modify a package via overlay ──────────────────────────

  # TODO: Write an overlay that changes hello's version to "3.0"
  overlay2 = final: prev: {
    # TODO: modify prev.hello to have version "3.0"
    # HINT: prev.hello // { version = "3.0"; }
  };
  # EXPECTED: (applyOverlay basePkgs overlay2).hello.version == "3.0"

  pkgsWithOverlay2 = applyOverlay basePkgs overlay2;

  # ── Exercise 3: Understand final vs prev ──────────────────────────────

  # This overlay demonstrates the difference:
  overlay3 = final: prev: {
    # Change openssl version
    openssl = prev.openssl // {
      version = "3.1";
    };

    # curl should use the NEW openssl (from final, after all overlays)
    curl = prev.curl // {
      deps = [ final.openssl ];
    };
  };

  pkgsWithOverlay3 = applyOverlay basePkgs overlay3;

  # TODO: What version of openssl does curl depend on?
  curl_openssl_version = null;
  # EXPECTED: "3.1" (because final.openssl has the overlaid version)
  # HINT: (pkgsWithOverlay3.curl.deps) is a list; the first element is openssl

  # ── Exercise 4: Stack two overlays ────────────────────────────────────

  # Overlay A adds a package:
  overlayA = final: prev: {
    myLib = {
      pname = "mylib";
      version = "1.0";
      deps = [ ];
    };
  };

  # Overlay B uses the package from A:
  overlayB = final: prev: {
    myApp = {
      pname = "myapp";
      version = "2.0";
      deps = [ final.myLib ];
    };
  };

  # Apply both overlays in sequence:
  pkgsAB = applyOverlay (applyOverlay basePkgs overlayA) overlayB;

  # TODO: What is pkgsAB.myApp.deps?
  myapp_deps = null;
  # EXPECTED: [ { pname = "mylib"; version = "1.0"; deps = []; } ]

  # ── Exercise 5: Real overlay pattern ──────────────────────────────────

  # TODO: Read your overlays/direnv-overlay.nix and answer:
  # Why does it use `prev.direnv.overrideAttrs` and not `final.direnv.overrideAttrs`?
  #
  # Set to true when you understand the answer:
  understood_final_prev = null;
  # EXPECTED: true
  # ANSWER: Using final.direnv would cause infinite recursion because
  # the overlay IS what defines final.direnv. You need prev to get
  # the version from before this overlay was applied.

in
{
  ex1_add =
    pkgsWithOverlay1 ? myTool
    &&
      pkgsWithOverlay1.myTool == {
        pname = "mytool";
        version = "1.0";
        deps = [ ];
      };

  ex2_modify = pkgsWithOverlay2.hello.version == "3.0";

  ex3_final_prev = curl_openssl_version == "3.1";

  ex4_stack =
    myapp_deps == [
      {
        pname = "mylib";
        version = "1.0";
        deps = [ ];
      }
    ];

  ex5_understood = understood_final_prev == true;
}
