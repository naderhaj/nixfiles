#!/bin/sh
set -e

# Capture available bytes before (APFS volumes share container free space)
before_avail=$(df -k /nix | tail -1 | awk '{print $4}')

echo "╔══════════════════════════════════════╗"
echo "║         Nix Garbage Collection       ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "▶ Before"
df -h /nix | tail -1
echo ""

echo "▶ Deleting old user profile generations..."
for profile in "$HOME"/.local/state/nix/profiles/*; do
  # skip numbered generation links; only touch the profile symlinks themselves
  case "$profile" in *-link) continue ;; esac
  [ -L "$profile" ] || continue
  nix profile wipe-history --profile "$profile"
done
echo ""

echo "▶ Deleting old system generations + garbage collection..."
sudo nix-collect-garbage --delete-old
echo ""

echo "▶ Optimising store (deduplicating identical files)..."
sudo nix store optimise
echo ""

# Capture available bytes after
after_avail=$(df -k /nix | tail -1 | awk '{print $4}')

echo "▶ After"
df -h /nix | tail -1
echo ""

# Compute saved (in KB, then convert)
saved_kb=$(( after_avail - before_avail ))

if [ "$saved_kb" -ge 1048576 ]; then
  saved=$(awk "BEGIN {printf \"%.1f GiB\", $saved_kb / 1048576}")
elif [ "$saved_kb" -ge 1024 ]; then
  saved=$(awk "BEGIN {printf \"%.1f MiB\", $saved_kb / 1024}")
else
  saved="${saved_kb} KiB"
fi

echo "══════════════════════════════════════"
if [ "$saved_kb" -gt 0 ]; then
  echo "  ✓ Freed: ${saved}"
else
  echo "  ✓ Nothing to collect (already clean)"
fi
echo "══════════════════════════════════════"
