{ config, pkgs, inputs, ...}:

{

  imports = [ ../lib/git-sync.nix ];

  home.file = {
    ".bashrc".source = ../dotfiles/.bashrc;
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".Xresources".source = ../dotfiles/.Xresources;
    ".config/i3/config".source = ../dotfiles/.config/i3/config;
    ".config/tmux/tmux.conf".source = ../dotfiles/.config/tmux/tmux.conf;
  };

  home.packages = with pkgs; [
    firefox
    evince
    texlive.combined.scheme-full
    inputs.bash-utils.packages."${pkgs.system}".label
    inputs.bash-utils.packages."${pkgs.system}".note
    jq
    unzip
  ];

  gurd.git-sync.keepassxc = {
    enable    = true;
    dir       = "keepassxc";
    cloneFrom = "git@github.com:Unigurd/keepassxc";
  };








  home.stateVersion = "23.11";
}
