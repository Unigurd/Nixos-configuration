{
  config,
  pkgs,
  inputs,
  isd,
  ...
}: {
  imports = [(import ../lib/emacs.nix pkgs).module];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sson";
  home.homeDirectory = "/home/sson";

  home.file = {
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".Xresources".source = ../dotfiles/.Xresources;
    ".config/i3/config".source = ../dotfiles/.config/i3/config;
    ".config/tmux/tmux.conf".source = ../dotfiles/.config/tmux/tmux.conf;
  };

  programs.git = {
    enable = true;
    userEmail = "sson@baselifescience.com";
  };

  programs.bash = {
    enable = true;
    profileExtra = "if [ -e /home/sson/.nix-profile/etc/profile.d/nix.sh ]; then . /home/sson/.nix-profile/etc/profile.d/nix.sh; fi";
    bashrcExtra = ''
      EDITOR=vi
      alias g=git
      # Silence direnv when entering a directory with a .envrc
      export DIRENV_LOG_FORMAT=
      # wordlist for emacs to use with word completion
      export WORDLIST=${pkgs.scowl}/share/dict/words.txt
      # `uv` saves its tools here so I need it to be in PATH at work
      export PATH=~/.local/bin:$PATH
    '';
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    xterm
    man-pages
    man-pages-posix
    python312Packages.python-lsp-server
    nil
    nodejs # Needed for the emacs copilot package
    pulseaudio
    pavucontrol
    keepassxc
    entr
    (import ../lib/filewatch.nix pkgs)
    isd.default
    pipx
    uv
    poetry
    htop
    strace
    nix-index
    # Commented because it doesn't work with nixpkgs of 2025-08-25
    # (azure-cli.withExtensions [azure-cli-extensions.azure-devops])
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with.
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
