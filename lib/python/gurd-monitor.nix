{
  python,
  xrandr,
  mkDerivation,
}:
mkDerivation {
  pname = "gurd-monitor";
  version = "0.0";

  src = ./.;
  nativeBuildInputs = [python];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/gurd-monitor <<EOF
    #!/bin/env sh
    PATH=${xrandr}/bin:$PATH PYTHONPATH="$src" exec ${python.interpreter} -m gurd.monitor
    EOF

    chmod +x $out/bin/gurd-monitor
  '';
}
