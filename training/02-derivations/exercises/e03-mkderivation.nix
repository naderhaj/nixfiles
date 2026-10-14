# Exercise 03: stdenv.mkDerivation
# Build: nix build -f training/02-derivations/exercises/e03-mkderivation.nix -L
# Then: ./result/bin/greet
#
# This exercise uses mkDerivation to package programs properly.
# NOTE: Requires nixpkgs. Run with:
#   nix build -f training/02-derivations/exercises/e03-mkderivation.nix \
#     --arg pkgs 'import <nixpkgs> {}'

{
  pkgs ? import <nixpkgs> { },
}:

let
  # ── Exercise 1: Package a shell script ────────────────────────────────
  #
  # TODO: Package the shell script below using mkDerivation.
  # The result should have an executable at $out/bin/greet
  greet-script = pkgs.stdenv.mkDerivation {
    pname = "greet";
    version = "1.0";

    # We have no tarball source — just create the script directly
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/greet << 'SCRIPT'
      #!/usr/bin/env bash
      echo "Hello from a Nix-packaged script!"
      echo "Today is $(date +%Y-%m-%d)"
      SCRIPT
      chmod +x $out/bin/greet
    '';

    # TODO: The script above uses `date` from coreutils and `bash`.
    # These are available via stdenv, so this works. But if the script
    # used a tool NOT in stdenv (like `jq`), you'd need:
    # nativeBuildInputs = [ pkgs.makeWrapper ];
    # postInstall = ''
    #   wrapProgram $out/bin/greet --prefix PATH : ${pkgs.jq}/bin
    # '';
  };

  # ── Exercise 2: Package a C program ───────────────────────────────────
  #
  # TODO: Uncomment and fix the derivation below to compile hello.c
  #
  # hello-c = pkgs.stdenv.mkDerivation {
  #   pname = "hello-c";
  #   version = "1.0";
  #   src = ./hello-c-src;  # You need to create this directory with hello.c
  #
  #   # stdenv provides gcc/clang automatically.
  #   # TODO: Write buildPhase to compile hello.c
  #   buildPhase = ''
  #     $CC -o hello hello.c
  #   '';
  #
  #   # TODO: Write installPhase to put the binary in $out/bin
  #   installPhase = ''
  #     mkdir -p $out/bin
  #     cp hello $out/bin/
  #   '';
  # };

  # ── Exercise 3: Use writeShellScriptBin (simpler) ─────────────────────
  #
  # For simple scripts, mkDerivation is overkill. Try the shorthand:
  simple-greet = pkgs.writeShellScriptBin "simple-greet" ''
    echo "This is much simpler!"
  '';
  # Build: nix build -f ... simple-greet
  # Run:   ./result/bin/simple-greet

in
# Change this to test different exercises:
greet-script
# hello-c
# simple-greet
