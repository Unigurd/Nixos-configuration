# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ...}:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [./hardware-configuration.nix];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # [  fileSystems."/mnt/boot" =
  # [    { device = "/dev/disk/by-label/BOOT";
  # [      fsType = "vfat"
  # [    };

  networking.hostName = "gurd-server"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "CET"; # "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkOverride 10 "us1";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.

  # environment.pathsToLink = ["/libexec"];

  services.xserver = {
    enable = true;

    layout = "us,dk";

    xkbOptions = "grp:win_space_toggle";

    desktopManager = {
    xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu # application launcher
        i3status # status bar
        i3lock # screen lock
      ];
    };
  };

  # services.xserver.enable = true;
  # services.xserver.windowManager.i3.enable = true;
  # services.xserver.displayManager.sddm.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us1";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };


  nixpkgs.config.allowUnfree = true;

  virtualisation.docker.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Have pulseaudio.service itself start at boot but after bluetooth
  # so bluetooth accepts sound connections from the start.
  systemd.user.services.pulseaudio.after = ["bluetooth.service"];
  systemd.user.targets.default.wants = ["pulseaudio.service"];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gurd = {
    initialPassword = "sabre";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs;
      # let bash-utils = (builtins.getFlake # "github:Unigurd/bash-utils").packages.x86_64-linux;
      #                                     "/home/gurd/bash/bash-utils").packages.x86_64-linux;
      [
        firefox
        thunderbird
        evince
        texlive.combined.scheme-full
        inputs.bash-utils.packages."${pkgs.system}".label
        inputs.bash-utils.packages."${pkgs.system}".note
      ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    emacs
    tmux
    guile_3_0
    git
    keepassxc
    pkgs.man-pages
    pkgs.man-pages-posix
  ];


  documentation.dev.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
