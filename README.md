# nix-lazy-env

**Why download and build programs you don't need?**

This repo provides a Nix function for lazy-downloaded/lazy-built environments.

# `lazyEnv` in action

`git clone` and `cd`;

```
$ nix-shell
[nix-shell]$ pandoc --help
these paths will be fetched (17.14 MiB download, 120.28 MiB unpacked):
  /nix/store/76xxck9cnzdhy5vsggb5birfnfv4wmmk-pandoc-2.7.1
copying path '/nix/store/76xxck9cnzdhy5vsggb5birfnfv4wmmk-pandoc-2.7.1' from 'https://cache.nixos.org'...
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
         to prevent gc-ing the result, make sure to use
             keep-outputs = true
         which can be set in nix.conf or nix.extraOptions (NixOS, nix-darwin)
path /nix/store/76xxck9cnzdhy5vsggb5birfnfv4wmmk-pandoc-2.7.1 now available; execing
pandoc [OPTIONS] [FILES]
  -f FORMAT, -r FORMAT  --from=FORMAT, --read=FORMAT
[...]

[nix-shell]$ pandoc --help
pandoc [OPTIONS] [FILES]
  -f FORMAT, -r FORMAT  --from=FORMAT, --read=FORMAT
[...]

[nix-shell]$ nix-store --delete /nix/store/76xxck9cnzdhy5vsggb5birfnfv4wmmk-pandoc-2.7.1
finding garbage collector roots...
0 store paths deleted, 0.00 MiB freed
error: cannot delete path '/nix/store/76xxck9cnzdhy5vsggb5birfnfv4wmmk-pandoc-2.7.1' since it is still alive

[nix-shell]$ nix-store -q --roots /nix/store/76xxck9cnzdhy5vsggb5birfnfv4wmmk-pandoc-2.7.1
{memory:395}

```

# Installation

Example `shell.nix`:

```
{ pkgs ? import <nixpkgs> {} }:
let
  lazyEnvSrc = builtins.fetchTarball "https://github.com/roberth/nix-lazy-env/archive/master.tar.gz"; # or pin it
  inherit (import lazyEnvSrc { inherit pkgs; }) lazyEnv;
  demoEnv = lazyEnv {
    name = "my-lazy-env"; # optional
    exes.figlet = pkgs.figlet;
    exes.qemu-img = pkgs.qemu;
  };
in
pkgs.mkShell {
  name = "demo-shell";
  nativeBuildInputs = [ demoEnv ];
}
```
