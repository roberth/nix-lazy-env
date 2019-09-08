{ pkgs ? import <nixpkgs> {} }:
let
  inherit (import ./. { inherit pkgs; }) lazyEnv;
in
  lazyEnv {
    name = "my-lazy-env";
    exes.figlet = pkgs.figlet;
    exes.hello = pkgs.hello.overrideAttrs (a: { n = 4; });
    exes.libreoffice = pkgs.libreoffice;
    exes.pandoc = pkgs.pandoc;
  }
