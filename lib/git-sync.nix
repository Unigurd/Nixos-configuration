{pkgs, lib, config, ...}:
let

  # I think this is enough to properly escape strings that go into systemd unit files
  escape      = str: lib.strings.escape [ "\"" "'" "\\" "\n" ] str;

  syncName   = key: escape "git-sync-${key}";

  syncType = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "git-sync timer daemon";

      dir = lib.mkOption {
        type        = lib.types.str;
        apply       = escape;
        description = "Relative path from users home to git repo.";
      };

      timeout = lib.mkOption {
        type        = lib.types.str;
        default     = "5s";
        apply       = escape;
        description = ''
              Time to wait before halting service.
              Must be a time span as specified in the systemd.time(7) manual.
            '';
      };

      cloneFrom = lib.mkOption {
        type        = lib.types.str;
        default     = "";
        apply       = escape;
        description = ''
              Git repository to clone if there isn't already a repo at the specified directory.
              The empty string means not to clone.
            '';
      };

      interval = lib.mkOption {
        type        = lib.types.str;
        default     = "1h";
        apply       = escape;
        description = ''
          Syncing interval. Corresponds to TimeoutSec for systemd timers.
          Must be a time span as specified in the systemd.time(7) manual.
        '';
      };

      accuracy = lib.mkOption {
        type        = lib.types.str;
        default     = "1m";
        apply       = escape;
        description = ''
          How accurate the timer is. Corresponds to AccuracySec for systemd timers.
          Must be a time span as specified in the systemd.time(7) manual.
        '';
      };
    };
  };


  makeService = key: cfg:  # key: str, cfg: syncType
    let name = syncName key;
        path = "${lib.makeBinPath [pkgs.openssh pkgs.git]}";
        command   = "${./git-sync.sh}";
        cloneMessage = "Specify repository to clone from by setting 'gurd.git-sync.cloneFrom'";
    in lib.attrsets.nameValuePair name
      (lib.mkIf cfg.enable {
        Unit.Description = name;
        Service = {
          Type        = "oneshot";
          TimeoutSec  = cfg.timeout;
          # The script is run through bash because I don't know a convenient way
          # to patch the shebang. That would be nice, since the command name
          # wouldn't be "bash" in the journalctl output.
          ExecStart   = "${pkgs.bash}/bin/bash ${command} '${cfg.dir}' '${cfg.cloneFrom}'";
          Environment = [
            "PATH=\"${path}\""                            # Systemd services run with empty PATHs in nixos
            "GIT_SYNC_CLONE_MESSAGE=\"${cloneMessage}\""  # Customize message for when clone fails
          ];
        };
      });

  makeTimer = key: cfg:  # key: str, cfg: syncType
    lib.attrsets.nameValuePair (syncName key) (
      lib.mkIf cfg.enable {
        Install.WantedBy = [ "timers.target" ];
        Timer = {
          AccuracySec     = cfg.accuracy;
          OnStartupSec    = "0m";
          OnUnitActiveSec = cfg.interval;
        };
      });
in {

  options = {
    gurd.git-sync = lib.mkOption {
      type = lib.types.attrsOf syncType;
      default = {};
    };
  };

  config = {
    systemd.user = {
      services = lib.attrsets.mapAttrs' makeService config.gurd.git-sync;
      timers   = lib.attrsets.mapAttrs' makeTimer config.gurd.git-sync;
    };
  };
}
