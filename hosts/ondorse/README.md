# Bootstrapping ondorse (fresh macOS)

Setting up the `ondorse` machine from a clean macOS install to a fully
declarative nix-darwin system (vanilla Nix, managed by this flake).

## 0. Prerequisites

Fresh macOS ships without developer tools. Install the Command Line Tools
(provides `git`):

```bash
xcode-select --install
```

You'll also need GitHub access — either add an SSH key
(`ssh-keygen -t ed25519` then add the public key to GitHub) or clone over
HTTPS in step 2.

## 1. Install vanilla Nix

Use the official installer (multi-user daemon mode is the default on macOS;
it creates the encrypted APFS volume, the mounter daemon and the build users):

```bash
sh <(curl -L https://nixos.org/nix/install)
```

Open a **new terminal** afterwards so the Nix shell hook is loaded.

## 2. Clone this repo

```bash
mkdir -p ~/projects && cd ~/projects
git clone git@github.com:hajlaoui-nader/nixfiles.git
cd nixfiles
```

## 3. First build + switch

The official installer doesn't enable flakes, so the very first build needs
the feature flags on the command line (one time only — after the first
switch, `nix.settings` in `hosts/ondorse/system.nix` bakes them into the
managed `nix.conf`):

```bash
nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.ondorse.system
```

nix-darwin refuses to overwrite config files it doesn't manage, so move the
installer's `nix.conf` aside before activating:

```bash
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
```

Then switch:

```bash
sudo ./result/sw/bin/darwin-rebuild switch --flake .#ondorse
```

If activation aborts complaining about other unmanaged files in `/etc`
(e.g. `/etc/bashrc`, `/etc/zshrc`), move them aside the same way
(`sudo mv <file> <file>.before-nix-darwin`) and re-run the switch.

## 4. Verify

Open a new terminal, then:

```bash
nix --version          # plain "nix (Nix) 2.x" — no vendor suffix
nix store info         # Store URL: daemon, Trusted: 1, no warnings
nix shell nixpkgs#hello -c hello   # flakes + pinned registry + caches work
```

Finally, reboot once and re-run `nix store info` to confirm the /nix volume
mounts and the daemon starts on its own.

## 5. GUI apps (manual installs)

These are installed outside Nix (no homebrew on these machines — direct
downloads, same as on mbp2023):

- **Rectangle** (window manager) — <https://rectangleapp.com>
- **Stats** (menu bar system monitor) — <https://github.com/exelban/stats/releases>
- **Ghostty** (terminal) — <https://ghostty.org/download>
  (its config is already managed by the flake via `modules/home/ghostty`,
  so it picks up `~/.config/ghostty/config` on first launch)
- **Flycut** (clipboard manager) — Mac App Store, or
  <https://github.com/TermiT/Flycut/releases>
- **Firefox** — <https://www.mozilla.org/firefox/mac/>
  (nixpkgs has no Firefox build for darwin, so only the app is manual — the
  profile and its add-ons come from `modules/home/firefox.nix`)

Post-install:

- Grant Rectangle and Flycut their Accessibility permissions when prompted
  (System Settings → Privacy & Security → Accessibility).
- Set the Flycut paste shortcut to **⌘⇧V**: Flycut menu bar icon →
  Preferences → Hotkeys → Main hotkey.
- Enable "Launch at login" in each app's preferences.

### Firefox

Switch first (step 3), *then* launch Firefox. home-manager writes the
`default` profile and drops the add-on `.xpi`s into it, so a first launch
after the switch picks them up rather than creating its own profile.

Add-ons are declared in `modules/home/firefox.nix` — uBlock Origin,
Bitwarden, Privacy Badger, DuckDuckGo, plus the French dictionary and
language pack. `extensions.autoDisableScopes = 0` in that module means they
arrive already enabled; nothing to click through.

Then sign in to Firefox Sync to pull over bookmarks, history and the
Bitwarden vault — that part can't be declared, since the encryption key is
derived from the account password. If Sync also syncs add-ons it will try to
reinstall ones that aren't in the flake; uncheck **Add-ons** in Sync settings
to keep `modules/home/firefox.nix` the single source of truth.

To bump add-on versions later:

```bash
nix flake update firefox-addons   # follows nixpkgs-unstable
```

## 6. Keyboard: swap Fn and left Control

Done by hand, to match mbp2023:

**System Settings → Keyboard → Keyboard Shortcuts… → Modifier Keys**, then
set **Control (^)** to `Fn/Globe` and **Fn/Globe** to `Control (^)`.

This one deliberately stays out of the flake. nix-darwin's
`system.keyboard.swapLeftCtrlAndFn` applies the swap with
`hidutil property --set` from the activation script, and hidutil mappings are
runtime-only — they are lost on reboot and would only come back on the next
`darwin-rebuild switch`. The System Settings route writes
`com.apple.keyboard.modifiermapping.*` into
`~/Library/Preferences/ByHost/.GlobalPreferences.<UUID>.plist`, which macOS
reapplies at every login. There is no nix-darwin option that writes that key
(`system.defaults.CustomUserPreferences` cannot target `-currentHost`).

Note macOS writes entries for *both* Control keys even though the UI shows a
single "Control" dropdown. Harmless — the built-in keyboard has no right
Control key.

## 7. Day-to-day

From here on the machine is fully declarative:

```bash
git pull
./scripts/darwin.sh ondorse    # build + switch
```

Nix itself, the daemon, `nix.conf`, the flake registry, weekly GC and store
optimisation are all managed by nix-darwin — never run `nix upgrade-nix` or
edit `/etc/nix/nix.conf` by hand. To update Nix (and everything else), bump
the flake inputs and switch (see the pin-update policy in the repo root
`CLAUDE.md`).
