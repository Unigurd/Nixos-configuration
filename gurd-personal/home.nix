{ config, pkgs, inputs, ...}:

{

  imports = [ ../lib/git-sync.nix ];

  home.file = {
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".Xresources".source = ../dotfiles/.Xresources;
    ".config/i3/config".source = ../dotfiles/.config/i3/config;
    ".bashrc".source = ../dotfiles/.bashrc;
  };

  home.packages = with pkgs; [
    firefox
    evince
    texlive.combined.scheme-full
    inputs.bash-utils.packages."${pkgs.system}".label
    inputs.bash-utils.packages."${pkgs.system}".note
  ];

  gurd.git-sync.keepassxc = {
    enable    = true;
    dir       = "keepassxc";
    cloneFrom = "git@github.com:Unigurd/keepassxc";
  };








  home.stateVersion = "23.11";
}
