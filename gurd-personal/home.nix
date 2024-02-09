{ config, pkgs, ...}:

{
  home.file.".gitconfig".source = ../dotfiles/.gitconfig;
  home.file.".Xresources".source = ../dotfiles/.Xresources;
  home.stateVersion = "23.11";
}
