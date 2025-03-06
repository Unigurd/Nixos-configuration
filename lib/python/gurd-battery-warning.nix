{
  mkDerivation,
  python,
  libnotify,
}: let
  package = mkDerivation {
    pname = "gurd-battery-warning";
    version = "0.0";
    src = ./.;
    nativeBuildInputs = [python];
    installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/gurd-battery-warning <<EOF
      #!/bin/env sh
      PATH=${libnotify}/bin:$PATH PYTHONPATH="$src" exec ${python.interpreter} -m gurd.battery-warning
      EOF
      chmod +x $out/bin/gurd-battery-warning
    '';
  };
  module = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options = {
      gurd.battery-warning.enable = pkgs.lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
    config = {
      systemd.user = pkgs.lib.mkIf config.gurd.battery-warning.enable {
        services.gurd-battery-warning = {
          Unit.Description = "Notify when battery is low.";
          Service = {
            Type = "oneshot";
            TimeoutSec = "10";
            ExecStart = "${package}/bin/gurd-battery-warning";
            # Environment = [
            #   "GURD_BATTERY_WARNING_CAPACITY_PERCENTAGE=40"
            # ];
          };
        };
        timers.gurd-battery-warning = {
          Install.WantedBy = ["timers.target"];
          Timer = {
            OnStartupSec = "0m";
            OnUnitActiveSec = "1m";
          };
        };
      };
      # Do I rather want to use this from configuration.nix?
      home.packages = [pkgs.dunst];
    };
  };
in {
  package = package;
  module = module;
}
