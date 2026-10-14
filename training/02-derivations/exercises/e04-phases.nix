# Exercise 04: Build Phases
# Build: nix build -f training/02-derivations/exercises/e04-phases.nix -L
#
# The -L flag shows build output so you can see the phase messages.
# Run with:
#   nix build -f training/02-derivations/exercises/e04-phases.nix \
#     --arg pkgs 'import <nixpkgs> {}' -L

{
  pkgs ? import <nixpkgs> { },
}:

let
  # ── Exercise 1: Phase observer ────────────────────────────────────────
  #
  # This derivation prints a message in each phase so you can see the order.
  # Build with -L and observe the output.
  phase-observer = pkgs.stdenv.mkDerivation {
    pname = "phase-observer";
    version = "0.1";

    # A trivial source — just an empty directory
    src = builtins.path {
      path = ./.;
      name = "phase-src";
      filter = path: type: false; # include nothing — empty dir
    };

    dontConfigure = true;

    postUnpack = ''echo "📦 postUnpack: source extracted to $sourceRoot"'';
    postPatch = ''echo "🩹 postPatch: patches applied (none in this case)"'';
    preBuild = ''echo "🔨 preBuild: about to build..."'';
    buildPhase = ''echo "🔨 buildPhase: building... (nothing to compile)"'';
    postBuild = ''echo "🔨 postBuild: build complete"'';
    preInstall = ''echo "📥 preInstall: about to install..."'';
    installPhase = ''
      echo "📥 installPhase: installing..."
      mkdir -p $out
      echo "phase-observer built successfully" > $out/result.txt
    '';
    postInstall = ''echo "📥 postInstall: install complete"'';
    postFixup = ''echo "🔧 postFixup: fixup complete (shebangs patched, etc.)"'';
  };

  # ── Exercise 2: postInstall wrapper ───────────────────────────────────
  #
  # TODO: Create a derivation that builds a script AND adds a man page
  # or README in postInstall.
  script-with-docs = pkgs.stdenv.mkDerivation {
    pname = "documented-script";
    version = "1.0";
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/mytool << 'SCRIPT'
      #!/usr/bin/env bash
      echo "Usage: mytool [options]"
      SCRIPT
      chmod +x $out/bin/mytool
    '';

    # TODO: Add a postInstall phase that creates $out/share/doc/mytool/README
    # with some documentation text
    # postInstall = ''
    #   mkdir -p $out/share/doc/mytool
    #   echo "mytool - a demo tool for learning Nix phases" > $out/share/doc/mytool/README
    # '';
  };

  # ── Exercise 3: substituteInPlace ─────────────────────────────────────
  #
  # This exercise mirrors the pattern from overlays/direnv-overlay.nix.
  # We create a "config file" and patch it during the build.
  patched-config = pkgs.stdenv.mkDerivation {
    pname = "patched-config";
    version = "1.0";

    # Create a source file to patch
    src = pkgs.writeText "app.conf" ''
      SERVER_HOST=localhost
      SERVER_PORT=3000
      DEBUG_MODE=true
      LOG_PATH=/tmp/app.log
    '';

    dontUnpack = true;

    buildPhase = ''
      cp $src app.conf

      # TODO: Use substituteInPlace to:
      # 1. Change SERVER_PORT from 3000 to 8080
      # 2. Change DEBUG_MODE from true to false
      # 3. Change LOG_PATH from /tmp/app.log to /var/log/app.log
      #
      # HINT: Look at overlays/direnv-overlay.nix for the syntax:
      # substituteInPlace app.conf \
      #   --replace-fail "SERVER_PORT=3000" "SERVER_PORT=8080" \
      #   --replace-fail "DEBUG_MODE=true" "DEBUG_MODE=false" \
      #   --replace-fail "LOG_PATH=/tmp/app.log" "LOG_PATH=/var/log/app.log"
    '';

    installPhase = ''
      mkdir -p $out
      cp app.conf $out/app.conf
    '';
  };

in
# Change this to test different exercises:
phase-observer
# script-with-docs
# patched-config
