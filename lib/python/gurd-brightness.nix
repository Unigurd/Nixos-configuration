{
  python,
  xrandr,
  mkDerivation,
}:
mkDerivation {
  pname = "gurd-brightness";
  version = "0.0";

  src = ./.;
  nativeBuildInputs = [python];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/gurd-brightness <<EOF
    #!/bin/env sh
    PATH=${xrandr}/bin:$PATH PYTHONPATH="$src" exec ${python.interpreter} -m gurd.brightness "\$@"
    EOF

    chmod +x $out/bin/gurd-brightness
  '';
}
