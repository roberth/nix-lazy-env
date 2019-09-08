{ pkgs ? import <nixpkgs> {} }:
let
  inherit (pkgs) lib;
  demo = import ./demo.nix { inherit pkgs; };
in
pkgs.mkShell {
  name = "demo-shell";
  nativeBuildInputs = [ demo ];
  shellHook = ''
    cat <<"EOF"
    This shell has only evaluated its tools, but hasn't built them.
    Try running one of these commands:
    ${lib.concatMapStringsSep "\n" (name: "$ ${name}") (lib.attrNames demo.exes)}
    EOF
  '';
}
