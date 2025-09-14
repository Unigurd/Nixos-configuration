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
    extraGroups = ["wheel" "networkmanager" "adbusers"]; # Enable ‘sudo’ for the user.
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
    (python312Packages.python-lsp-server.overridePythonAttrs
      (old: {
        dependencies = old.dependencies ++ old.optional-dependencies.rope;
      }))
    python312Packages.ruff
    htop
    (python312.withPackages (ps: [
      # Needed for the eduroam setup script
      ps.dbus-python
      # Needed for jupyter notebooks in vs code for mekrel
      ps.jupyter
      ps.notebook
      ps.ipykernel
      ps.pip
      ps.numpy
      ps.matplotlib
    ]))
    isd.default
    self.packages.x86_64-linux.gurd-python
  ];

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
  documentation.man.generateCaches = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "gurd-personal";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default
  networking.extraHosts = "192.168.0.100 gurd-server";

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

  programs.adb.enable = true;

  # DO NOT CHANGE
  system.stateVersion = "22.05"; # Did you read the comment?
}
