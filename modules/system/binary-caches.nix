# Binary caches beyond cache.nixos.org, shared by all hosts. `extra-` appends
# to the defaults instead of replacing them. Spelled the same in NixOS and
# nix-darwin.
{
  nix.settings = {
    # Filled by CI (.github/workflows/build.yml) with everything it builds.
    extra-substituters = [ "https://naderhaj.cachix.org" ];
    extra-trusted-public-keys = [
      "naderhaj.cachix.org-1:6FETXG/Ne0wJiw2UUwD/OXovM5kZg6Ei3r7pXLp636U="
    ];
  };
}
