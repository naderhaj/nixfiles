{ pkgs, lib, ... }:
{
  home.packages = [
    pkgs.man-pages # linux programmer's manual
    pkgs.zip # archives
    pkgs.unzip # archives
    pkgs.lsd
    pkgs.docker
    pkgs.jq
    pkgs.docker-compose # docker manager
    pkgs.fastfetch # command-line system information
    pkgs.ripgrep # fast grep
    pkgs.tree # display files in a tree view
    pkgs.eza # a better `ls`
    pkgs.bottom # a better `top`
    pkgs.tree-sitter # syntax highlighting
    pkgs.fd # a better `find`
    pkgs.file # file type
    pkgs.xxd # hexdump
    pkgs.nmap # network scanner
    pkgs.duf # disk usage
    pkgs.lua-language-server
    pkgs.lua
    pkgs.go
    pkgs.jdk # Java Development Kit
    pkgs.gcc14
    pkgs.cargo
    pkgs.rustc
    pkgs.inetutils # provides `ftp`, `telnet`, ...
    pkgs.dig # DNS lookup
    pkgs.openresolv # DNS resolver
    pkgs.unstable.claude-code
    pkgs.nodejs_24
    pkgs.gh
    pkgs.unstable.opencode
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.coreutils # provides `dd` with --status=progress
    pkgs.colima # docker daemon (lightweight VM), lower battery use than Docker Desktop
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    pkgs.gdb # gdb doesn't build on macOS, only install on Linux
    pkgs.iputils # provides `ping`, `ifconfig`, ...
    pkgs.libuuid # `uuidgen` (already pre-installed on mac)
    pkgs.font-awesome # awesome fonts
    pkgs.material-design-icons # fonts with glyphs
    pkgs.vscode
  ];
}
