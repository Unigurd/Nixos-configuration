{
  config,
  pkgs,
  lib,
  inputs,
  isd,
  self,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;
  imports = [../lib/xserver.nix ../lib/i18n.nix];

  # User gurd
  users.users.gurd = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "adbusers" "plugdev"]; # Enable ‘sudo’ for the user.
  };

  # Enable the X11 windowing system with i3
  gurd.i3.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    neovim
    dig
    wget
    tmux
    git
    keepassxc
    xclip # xclip is needed for keepassxc-cli to be able to copy to clipboard
    man-pages
    man-pages-posix
    htop
    (python312.withPackages (ps: [
      # Needed for the eduroam setup script
      ps.dbus-python
      # Needed for jupyter notebooks in vs code for mekrel
      # ps.jupyter
      # ps.notebook
      # ps.ipykernel
      # ps.pip
      # ps.numpy
      # ps.matplotlib
      # ps.scikit-learn
    ]))
    self.packages.x86_64-linux.gurd-python
  ];

  programs.gnupg.agent.enable = true;

  services.tailscale.enable = true;

  services.logind.settings.Login = {
    IdleAction = "ignore";
    IdleActionSec = 0;
  };

  environment.wordlist.enable = true;

  # Developer documentation (How does this compare to pkgs.man-pages(-posix)?
  documentation.dev.enable = true;
  # Generate mandb cache. Emacs needs this for the `man` command to generate
  # suggestions.
  documentation.man.cache.enable = true;

  # Temporary fix:
  # https://github.com/NixOS/nixpkgs/issues/499166#issuecomment-4124861759
  documentation.doc.enable = false;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "gurd-personal";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default
  networking.extraHosts = "192.168.0.165 gurd-server";

  # Docker
  virtualisation.docker.enable = true;

  # Time zone
  time.timeZone = "Europe/Copenhagen";

  # Enable CUPS to print documents
  # Disabled due to recent CUPS vulnerability
  # services.printing.enable = true;

  # Source ~/.bashrc from login shells
  # Check that the shell is bash and that it is interactive.
  # $- is current shell options
  programs.bash.loginShellInit = ''[[ -n "$BASH" ]] && [[ "$-" == *i* ]] && . ~/.bashrc'';

  # adb has been disabled because of the following error after a nixpkgs upgrade:
  # Failed assertions:
  # - The option definition `programs.adb' in `/nix/store/p0947ifyib9rpywx7ijsjkmiba56pljx-source/gurd-personal/configuration.nix' no longer has any effect; please remove it.
  # This option is no longer needed as systemd 258 handles uaccess rules automatically. Please add `pkgs.android-tools` to your system packages to get the adb command.
  # programs.adb.enable = true;

  nix.registry.gurd.flake = self;

  # DO NOT CHANGE
  system.stateVersion = "22.05"; # Did you read the comment?
}
