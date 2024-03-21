# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ...}:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  imports = [./hardware-configuration.nix];

  # User gurd
  users.users.gurd = {
    initialPassword = "sabre";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs;
      [
        firefox
        evince
        texlive.combined.scheme-full
        inputs.bash-utils.packages."${pkgs.system}".label
        inputs.bash-utils.packages."${pkgs.system}".note
      ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim wget emacs tmux guile_3_0 git keepassxc pkgs.man-pages pkgs.man-pages-posix];

  # Developer documentation (How does this compare to pkgs.man-pages(-posix)?
  documentation.dev.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "gurd-personal"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Docker
  virtualisation.docker.enable = true;

  # Time zone
  time.timeZone = "Europe/Copenhagen";

  # Internationalisation
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkOverride 10 "us1";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system
  services.xserver = {
    enable = true;
    xkb.options = "grp:win_space_toggle";
    xkb.layout = "us,dk";
    libinput.enable = true; # Enable touchpad support (enabled default in most desktop managers)
    desktopManager.xterm.enable = false;
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

  # DO NOT CHANGE
  system.stateVersion = "22.05"; # Did you read the comment?

}
