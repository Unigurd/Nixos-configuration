{
  pkgs,
  xrandr ? pkgs.xorg.xrandr,
  ...
}: let
  system = "x86_64-linux";
  python = pkgs.python312.withPackages (
    ps: let
      pyedid = ps.buildPythonPackage rec {
        pname = "pyedid";
        version = "1.0.3";

        src = pkgs.fetchPypi {
          inherit pname version;
          hash = "sha256-5huO97aAbsU26pcb9lDjRw9qnNrplNb1DS2Xw/jxuPQ=";
        };

        dependencies = [ps.requests];
      };
    in [pyedid]
  );
  gurd-battery-warning = import ./gurd-battery-warning.nix {
    mkDerivation = pkgs.stdenv.mkDerivation;
    python = python;
    libnotify = pkgs.libnotify;
  };
in rec {
  devShells."${system}".default = pkgs.mkShell {
    packages = [
      python
      pkgs.python312Packages.pytest
      xrandr
      pkgs.libnotify
    ];
    shellHook = "export PYTHONPATH=$PWD/lib/python:$PYTHONPATH";
  };
  packages."${system}" = {
    gurd-python = pkgs.stdenv.mkDerivation {
      pname = "gurd-python";
      version = "0.0";

      src = ./.;
      nativeBuildInputs = [python];

      installPhase = ''
        mkdir -p $out/bin

        cat > $out/bin/gurd-monitor <<EOF
        #!/bin/env sh
        PATH=${xrandr}/bin:$PATH PYTHONPATH="$src" exec ${python.interpreter} -m gurd.monitor
        EOF

        cat > $out/bin/gurd-brightness <<EOF
        #!/bin/env sh
        PATH=${xrandr}/bin:$PATH PYTHONPATH="$src" exec ${python.interpreter} -m gurd.brightness "\$@"
        EOF

        chmod +x $out/bin/gurd-monitor
        chmod +x $out/bin/gurd-brightness
      '';
    };

    gurd-battery-warning = gurd-battery-warning.package;
  };

  nixosModules."${system}".gurd-battery-warning = gurd-battery-warning.module;
}
