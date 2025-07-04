{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;
  imports = [../lib/xserver.nix ../lib/i18n.nix ../lib/jellyfin.nix];

  # User gurd
  users.users.gurd = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "jellyfin"]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      # To ssh in from gurd-personal
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5BXPPjBBmXO5EMK5t4Vo24b77Kv0zcYYXFDdb2PM35 Sigurddam@hotmail.com"
    ];
  };

  # Enable X11 with i3
  gurd.i3.enable = true;

  services.logind.extraConfig = ''
    IdleAction=ignore
    HandleLidSwitch=ignore
    HandleLidSwitchExternalPower=ignore
    HandleLidSwitchDocked=ignore
  '';

  gurd.jellyfin = {
    enable = true;
    openFirewall = false;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    home-manager
    vim
    dig
    wget
    tmux
    git
    keepassxc
    pkgs.man-pages
    pkgs.man-pages-posix
  ];

  services.tailscale = {
    enable = true;
  };

  # Developer documentation (How does this compare to pkgs.man-pages(-posix)?)
  documentation.dev.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "gurd-server";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default

  # Docker
  virtualisation.docker.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Have pulseaudio.service itself start at boot but after bluetooth
  # so bluetooth accepts sound connections from the start.
  systemd.user.services.pulseaudio.after = ["bluetooth.service"];
  systemd.user.targets.default.wants = ["pulseaudio.service"];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.X11Forwarding = true;
  };

  # Enable AdGuard Home
  services.adguardhome = {
    enable = true;
    # Could be fun but requires configuration I can't be bothered to do
    # mutableSettings = false;
    settings.users = [
      {
        name = "Unigurd";
        password = "$2y$10$zF9iCCc3Tge7J0FoNusnbe22qS/WAVU9FMDCZhQz.tdyN39tsdpGe";
      }
    ];
  };

  services.logind.lidSwitch = "ignore";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [22 8096]; # SSH -- OpenSSH
  networking.firewall.allowedUDPPorts = [53]; # DNS -- Adguard Home

  # Source ~/.bashrc from login shells. Needed when ssh'ing in.
  # Check that the shell is bash and that it is interactive.
  # $- is current shell options
  programs.bash.loginShellInit = ''[[ -n "$BASH" ]] && [[ "$-" == *i* ]] && . ~/.bashrc'';

  # DO NOT CHANGE
  system.stateVersion = "22.05"; # Did you read the comment?
}
