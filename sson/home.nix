{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sson";
  home.homeDirectory = "/home/sson";

  home.file = {
    ".bashrc".source = ../dotfiles/.bashrc;
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".Xresources".source = ../dotfiles/.Xresources;
    ".config/i3/config".source = ../dotfiles/.config/i3/config;
    ".config/tmux/tmux.conf".source = ../dotfiles/.config/tmux/tmux.conf;
  };

  programs.git = {
    enable = true;
    userEmail = "sson@baselifescience.com";
  };

  home.packages = with pkgs; [
    (import ../lib/emacs.nix pkgs)
    python312Packages.python-lsp-server
    nil
    nodejs # Needed for the emacs copilot package
    pulseaudio
    pavucontrol
    keepassxc
    (import ../lib/filewatch.nix pkgs)
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
