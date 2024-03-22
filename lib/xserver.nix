{pkgs, lib, config, ...}: {
  options = {
    gurd.i3.enable = lib.mkEnableOption "gurd's i3";
  };

  config = lib.mkIf config.gurd.i3.enable {
    services.xserver = {
      enable = true;
      xkb.options = "grp:win_space_toggle";
      xkb.layout = "us,dk";
      libinput.enable = true; # Enable touchpad support (enabled default in most desktop managers)
      displayManager.defaultSession = "none+i3";
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
    EndSection
    Section "Monitor"
      Identifier "HDMI-2"
      Option "Above" "eDP-1"
    EndSection
'';
    };
  };
}
