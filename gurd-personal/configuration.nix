{ config, pkgs, lib, inputs, ...}: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  imports = [../lib/xserver.nix ../lib/i18n.nix];

  # User gurd
  users.users.gurd = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  # Enable the X11 windowing system with i3
  gurd.i3.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim emacs
    dig wget
    tmux
    git
    keepassxc xclip  # xclip is needed for keepassxc-cli to be able to copy to clipboard
    pkgs.man-pages pkgs.man-pages-posix
  ];

  # Developer documentation (How does this compare to pkgs.man-pages(-posix)?
  documentation.dev.enable = true;

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "gurd-personal";
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default
  networking.extraHosts = "192.168.0.100 gurd-server";

  # Docker
  virtualisation.docker.enable = true;

  # Time zone
  time.timeZone = "Europe/Copenhagen";

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Source ~/.bashrc from login shells
  # Check that the shell is bash and that it is interactive.
  # $- is current shell options
  programs.bash.loginShellInit = ''[[ -n "$BASH" ]] && [[ "$-" == *i* ]] && . ~/.bashrc'';





  # DO NOT CHANGE
  system.stateVersion = "22.05"; # Did you read the comment?

}
