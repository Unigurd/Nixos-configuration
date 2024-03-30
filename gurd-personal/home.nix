{ config, pkgs, ...}:

{
  home.file.".gitconfig".source = ../dotfiles/.gitconfig;
  home.file.".Xresources".source = ../dotfiles/.Xresources;
  home.file.".config/i3/config".source = ../dotfiles/.config/i3/config;
  home.file.".bashrc".source = ../dotfiles/.bashrc;

  home.packages = with pkgs; [
    firefox
    evince
    texlive.combined.scheme-full
    inputs.bash-utils.packages."${pkgs.system}".label
    inputs.bash-utils.packages."${pkgs.system}".note
  ];








  home.stateVersion = "23.11";
}
