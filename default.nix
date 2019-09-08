{ pkgs ? import <nixpkgs> {} }:
let
  inherit (pkgs)
    runCommand
    lib
    ;
in
{
  lazyEnv =
    { name ? "lazy-env"
    , exes
    , assumeDrvCache ? false
    }:
      runCommand name {
        passthru = { inherit exes; };
      } ''
        mkdir -p $out/bin
        ${
          lib.concatMapStringsSep
            "\n"
            ({ name, value }:
            let
              drvPath = refDrv value.drvPath;
              bin = lib.getBin value;
              binPath = builtins.unsafeDiscardStringContext bin.outPath;
              exePath = "${binPath}/bin/${name}";
              refDrv =
                if assumeDrvCache
                then builtins.unsafeDiscardStringContext
                else builtins.unsafeDiscardOutputDependency;
            in ''
              cat >$out/bin/${name} <<"EOF"
              #!/usr/bin/env bash
              set -euo pipefail
              if [[ -e ${lib.escapeShellArg binPath} ]]; then
                exec ${lib.escapeShellArg exePath} "$@"
              fi
              nix-store -r ${drvPath}!${bin.outputName} >/dev/null
              cat 1>&2 <<"EOM"
                       to prevent gc-ing the result, make sure to use
                           keep-outputs = true
                       which can be set in nix.conf or nix.extraOptions (NixOS, nix-darwin)
              path ${binPath} now available; execing
              EOM
              exec ${lib.escapeShellArg exePath} "$@"
              EOF
              chmod a+x $out/bin/${name}
              ''
            )
            (lib.mapAttrsToList
              lib.nameValuePair
              exes
            )
        }
      '';

}
