# Exercise 02: Raw Derivation
# Build: nix build -f training/02-derivations/exercises/e02-raw-derivation.nix -L
# Then: cat result
#
# This exercise creates derivations using only builtins.derivation.

let
  system = builtins.currentSystem;

  # ── Exercise 1: Hello world derivation ────────────────────────────────
  #
  # TODO: Create a derivation that writes "Hello from a raw derivation!" to $out
  #
  # HINT:
  #   builtins.derivation {
  #     name = "hello-raw";
  #     inherit system;
  #     builder = "/bin/sh";
  #     args = [ "-c" "echo 'Hello from a raw derivation!' > $out" ];
  #   }
  hello = builtins.derivation {
    name = "hello-raw";
    inherit system;
    builder = "/bin/sh";
    # TODO: Fill in args to write "Hello from a raw derivation!" to $out
    args = [
      "-c"
      "echo Hello from a raw derivation > $out"
    ];
  };

  # ── Exercise 2: Using environment variables ───────────────────────────
  #
  # TODO: Create a derivation where you pass `greeting` as an attribute
  # and the builder script uses $greeting to write to $out
  greeting_drv = builtins.derivation {
    name = "greeting";
    inherit system;
    builder = "/bin/sh";
    # TODO: Add a `greeting` attribute and use $greeting in args
    greeting = "Nix is powerful";
    args = [
      "-c"
      "echo TODO > $out"
    ];
    # HINT: args = [ "-c" "echo $greeting > $out" ];
  };

  # ── Exercise 3: Derivation as dependency ──────────────────────────────
  #
  # TODO: Create a derivation that reads the output of `hello` and
  # wraps it in "=== ... ==="
  wrapper = builtins.derivation {
    name = "wrapper";
    inherit system;
    builder = "/bin/sh";
    # TODO: Use ${hello} to reference the hello derivation's output
    args = [
      "-c"
      "echo TODO > $out"
    ];
    # HINT: args = [ "-c" ''echo "=== $(cat ${hello}) ===" > $out'' ];
  };

  # ── Exercise 4: Directory output ──────────────────────────────────────
  #
  # TODO: Create a derivation that produces a directory with two files:
  #   $out/hello.txt  containing "hello"
  #   $out/world.txt  containing "world"
  dir_drv = builtins.derivation {
    name = "dir-output";
    inherit system;
    builder = "/bin/sh";
    # TODO: Create a directory at $out with two files
    args = [
      "-c"
      ''
        mkdir -p $out
        echo TODO
      ''
    ];
    # HINT:
    # args = [ "-c" ''
    #   mkdir -p $out
    #   echo hello > $out/hello.txt
    #   echo world > $out/world.txt
    # '' ];
  };

in
# Change this to test different exercises:
# hello, greeting_drv, wrapper, or dir_drv
hello
