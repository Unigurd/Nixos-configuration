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
  packages."${system}" = rec {
    gurd-monitor = import ./gurd-monitor.nix {
      python = python;
      xrandr = xrandr;
      mkDerivation = pkgs.stdenv.mkDerivation;
    };

    gurd-brightness = import ./gurd-brightness.nix {
      python = python;
      xrandr = xrandr;
      mkDerivation = pkgs.stdenv.mkDerivation;
    };

    gurd-python = pkgs.stdenv.mkDerivation {
      pname = "gurd-python";
      version = "0.0";
      dontUnpack = true;

      inherit gurd-monitor gurd-brightness;

      installPhase = ''
        mkdir -p $out/bin
        ln --symbolic ${gurd-monitor}/bin/gurd-monitor       $out/bin/gurd-monitor
        ln --symbolic ${gurd-brightness}/bin/gurd-brightness $out/bin/gurd-brightness
      '';
    };

    gurd-battery-warning = gurd-battery-warning.package;
  };

  nixosModules."${system}".gurd-battery-warning = gurd-battery-warning.module;
}
