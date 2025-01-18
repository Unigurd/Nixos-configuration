{
  pkgs,
  lib,
  config,
  ...
}: let
  t = lib.types;
  a = lib.attrsets;

  # I think this is enough to properly escape strings that go into systemd unit files
  escape = str: lib.strings.escape ["\"" "'" "\\" "\n"] str;

  syncName = key: escape "git-sync-${key}";

  syncType = t.submodule {
    options = {
      enable = lib.mkEnableOption "git-sync timer daemon";

      dir = lib.mkOption {
        type = t.str;
        apply = escape;
        description = "Relative path from users home to git repo.";
      };

      timeout = lib.mkOption {
        type = t.str;
        default = "5s";
        apply = escape;
        description = ''
          Time to wait before halting service.
          Must be a time span as specified in the systemd.time(7) manual.
        '';
      };

      cloneFrom = lib.mkOption {
        type = t.str;
        default = "";
        apply = escape;
        description = ''
          Git repository to clone if there isn't already a repo at the specified directory.
          The empty string means not to clone.
        '';
      };

      interval = lib.mkOption {
        type = t.str;
        default = "1h";
        apply = escape;
        description = ''
          Syncing interval. Corresponds to TimeoutSec for systemd timers.
          Must be a time span as specified in the systemd.time(7) manual.
        '';
      };

      accuracy = lib.mkOption {
        type = t.nullOr t.str;
        default = builtins.null;
        apply = a:
          if builtins.isString a
          then escape a
          else a;
        description = ''
          How accurate the timer is. Corresponds to AccuracySec for systemd timers.
          Must be a time span as specified in the systemd.time(7) manual.
        '';
      };
    };
  };

  makeService = key: cfg:
  # key: str, cfg: syncType
  let
    name = syncName key;
    path = "${lib.makeBinPath [pkgs.openssh pkgs.git]}";
    command = "${./git-sync.sh}";
    cloneMessage = "Specify repository to clone from by setting 'gurd.git-sync.cloneFrom'";
  in
    a.nameValuePair name
    (lib.mkIf cfg.enable {
      Unit.Description = name;
      Service = {
        Type = "oneshot";
        TimeoutSec = cfg.timeout;
        # The script is run through bash because I don't know a convenient way
        # to patch the shebang. That would be nice, since the command name
        # wouldn't be "bash" in the journalctl output.
        ExecStart = "${pkgs.bash}/bin/bash ${command} '${cfg.dir}' '${cfg.cloneFrom}'";
        Environment = [
          "PATH=\"${path}\"" # Systemd services run with empty PATHs in nixos
          "GIT_SYNC_CLONE_MESSAGE=\"${cloneMessage}\"" # Customize message for when clone fails
        ];
      };
    });

  makeTimer = key: cfg:
  # key: str, cfg: syncType
    a.nameValuePair (syncName key) (
      lib.mkIf cfg.enable {
        Install.WantedBy = ["timers.target"];
        Timer = {
          AccuracySec = lib.mkIf (!builtins.isNull cfg.accuracy) cfg.accuracy;
          OnStartupSec = "0m";
          OnUnitActiveSec = cfg.interval;
        };
      }
    );
in {
  options = {
    gurd.git-sync = lib.mkOption {
      type = t.attrsOf syncType;
      default = {};
    };
  };

  config = {
    systemd.user = {
      services = a.mapAttrs' makeService config.gurd.git-sync;
      timers = a.mapAttrs' makeTimer config.gurd.git-sync;
    };
  };
}
