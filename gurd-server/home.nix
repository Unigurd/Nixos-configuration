{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "gurd";
  home.homeDirectory = "/home/gurd";

  imports = [../lib/git-sync.nix];

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
    inputs.bash-utils.packages."${pkgs.system}".label
    inputs.bash-utils.packages."${pkgs.system}".note
    htop
    jq
    unzip
  ];

  gurd.git-sync.keepassxc = {
    enable = true;
    dir = "keepassxc";
    cloneFrom = "git@github.com:Unigurd/keepassxc";
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with.
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
