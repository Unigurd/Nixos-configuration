{ config, pkgs, ...}:

{
  home.file.".gitconfig".source = ./home/.gitconfig;
  home.file.".Xresources".source = ./home/.Xresources;
  home.stateVersion = "23.11";
}
