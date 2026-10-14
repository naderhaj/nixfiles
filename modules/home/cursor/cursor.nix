# Create this file at /etc/nixos/packages/cursor.nix
{ pkgs, ... }:
let
  pname = "cursor";
  version = "1.4.5";

  # nix-prefetch-url "https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/1.7"
  # 0mg6byzhadh6k8jrbnns8p7g66x34vwvb5h46kk7fmmjc8cg27v4
  # nix hash convert --hash-algo sha256 0mg6byzhadh6k8jrbnns8p7g66x34vwvb5h46kk7fmmjc8cg27v4
  src = pkgs.fetchurl {
    url = "https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/1.7";
    hash = "sha256-ZB/xGGKyVnfmNASWtfkmoxvzzkXa2pUlmgY2Bb9f5lU=";
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in
with pkgs;
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-quiet 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share

    if [ -e ${appimageContents}/AppRun ]; then
      install -m 755 -D ${appimageContents}/AppRun $out/bin/${pname}-${version}
      if [ ! -L $out/bin/${pname} ]; then
        ln -s $out/bin/${pname}-${version} $out/bin/${pname}
      fi
    else
      echo "Error: Binary not found in extracted AppImage contents."
      exit 1
    fi
  '';

  extraBwrapArgs = [ "--bind-try /etc/nixos/ /etc/nixos/" ];

  dieWithParent = false;

  extraPkgs = pkgs: [
    unzip
    autoPatchelfHook
    asar
    (buildPackages.wrapGAppsHook.override {
      inherit (buildPackages) makeWrapper;
    })
  ];
}
