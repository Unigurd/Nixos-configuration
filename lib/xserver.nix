{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    gurd.i3.enable = lib.mkEnableOption "gurd's i3";
  };

  config = lib.mkIf config.gurd.i3.enable {
    # Previously services.xserver.displayManager.defaultSession
    # and services.xserver.libinput.enable. That's why they're here.
    services.displayManager.defaultSession = "none+i3";
    services.libinput.enable = true; # Enable touchpad support. enabled default in most desktop managers

    services.xserver = {
      enable = true;
      xkb.options = "grp:win_space_toggle";
      xkb.layout = "us,dk";
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu # application launcher
          i3status # status bar
          i3lock # screen lock
        ];
      };

      extraConfig = ''
        Section "Monitor"
          Identifier "eDP-1
          Option "Position" "1600 1440"
        EndSection
        Section "Monitor"
          Identifier "DP-1"
          Option "PreferredMode" "5120x1440"
          Option "Position" "0 0"
        EndSection
        Section "Monitor"
          Identifier "DP-2"
          Option "PreferredMode" "5120x1440"
          Option "Position" "0 0"
        EndSection
        Section "Monitor"
          Identifier "HDMI-2"
          Option "Above" "eDP-1"
        EndSection
      '';
    };
  };
}
