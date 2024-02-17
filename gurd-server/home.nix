{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "gurd";
  home.homeDirectory = "/home/gurd";

  home.file.".gitconfig".source = ../dotfiles/.gitconfig;
  home.file.".Xresources".source = ../dotfiles/.Xresources;
  home.file.".bashrc".source = ../dotfiles/.bashrc;
  home.file.".config/i3/config".source = ../dotfiles/.config/i3/config;

  # This value determines the Home Manager release that your configuration is
  # compatible with.
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
