# Exercise 02: The callPackage Pattern
# Run: nix eval -f training/04-nixpkgs/exercises/e02-callpackage.nix
#
# This exercise builds understanding of callPackage from the ground up.

let
  # ── Exercise 1: builtins.functionArgs ─────────────────────────────────
  #
  # This is the magic behind callPackage.

  myFunc =
    {
      a,
      b,
      c ? 3,
    }:
    a + b + c;

  # TODO: What does builtins.functionArgs myFunc return?
  funcArgs = null;
  # EXPECTED: { a = false; b = false; c = true; }
  # The values indicate whether the argument has a default (true) or not (false).

  # ── Exercise 2: Implement a minimal callPackage ───────────────────────
  #
  # Fill in the implementation below.

  # A fake "package set" to inject from:
  fakePkgs = {
    stdenv = "fake-stdenv";
    fetchurl = "fake-fetchurl";
    openssl = "fake-openssl";
    zlib = "fake-zlib";
  };

  # TODO: Implement callPackage
  # It should:
  #   1. Get the function's argument names with builtins.functionArgs
  #   2. For each arg, use the override if provided, otherwise look in fakePkgs
  #   3. Call the function with the resolved arguments
  myCallPackage =
    fn: overrides:
    let
      args = builtins.functionArgs fn;
      resolved = builtins.mapAttrs (
        name: _hasDefault:
        # TODO: if name is in overrides, use override; else use fakePkgs
        null
      ) args;
    in
    fn resolved;
  # HINT: overrides.${name} or fakePkgs.${name}

  # Test functions that simulate package definitions:
  myPackageA = { stdenv, fetchurl }: {
    name = "pkg-a";
    builder = stdenv;
    fetcher = fetchurl;
  };

  myPackageB =
    {
      stdenv,
      openssl,
      zlib,
    }:
    {
      name = "pkg-b";
      deps = [
        openssl
        zlib
      ];
    };

  # TODO: Call them with myCallPackage
  resultA = null;
  # EXPECTED: { name = "pkg-a"; builder = "fake-stdenv"; fetcher = "fake-fetchurl"; }

  resultB = null;
  # EXPECTED: { name = "pkg-b"; deps = [ "fake-openssl" "fake-zlib" ]; }

  # ── Exercise 3: Override a dependency ─────────────────────────────────
  #
  # TODO: Use myCallPackage to call myPackageB but override openssl
  resultB_override = null;
  # EXPECTED: { name = "pkg-b"; deps = [ "custom-openssl" "fake-zlib" ]; }
  # HINT: myCallPackage myPackageB { openssl = "custom-openssl"; }

  # ── Exercise 4: .override in real nixpkgs ─────────────────────────────
  #
  # In a nix repl, try:
  #   pkgs = import <nixpkgs> {}
  #   pkgs.hello.override { stdenv = pkgs.clangStdenv; }
  #
  # This re-calls the hello function with clangStdenv instead of the default.
  # No need to code anything — just understand the concept.
  understood_override = null;
  # Set to true when you've tried it
  # EXPECTED: true

in
{
  ex1_functionArgs =
    funcArgs == {
      a = false;
      b = false;
      c = true;
    };

  ex2_callPackage =
    resultA == {
      name = "pkg-a";
      builder = "fake-stdenv";
      fetcher = "fake-fetchurl";
    }
    &&
      resultB == {
        name = "pkg-b";
        deps = [
          "fake-openssl"
          "fake-zlib"
        ];
      };

  ex3_override =
    resultB_override == {
      name = "pkg-b";
      deps = [
        "custom-openssl"
        "fake-zlib"
      ];
    };

  ex4_understood = understood_override == true;
}
