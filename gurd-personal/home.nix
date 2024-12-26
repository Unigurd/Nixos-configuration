{ config, pkgs, inputs, ...}:

{

  imports = [ ../lib/git-sync.nix ../lib/firefox.nix];

  home.file = {
    ".bashrc".source = ../dotfiles/.bashrc;
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".Xresources".source = ../dotfiles/.Xresources;
    ".config/i3/config".source = ../dotfiles/.config/i3/config;
    ".config/tmux/tmux.conf".source = ../dotfiles/.config/tmux/tmux.conf;
  };

  programs.git = {
    enable = true;
    userEmail = "Sigurddam@hotmail.com";
  };

  home.packages = with pkgs; [
    evince
    texlive.combined.scheme-full
    ghostscript # pdf2dsc from this package is used for `preview-latex` in emacs
    inputs.bash-utils.packages."${pkgs.system}".label
    inputs.bash-utils.packages."${pkgs.system}".note
    jq
    unzip
    binutils
  ];

  gurd.git-sync.keepassxc = {
    enable    = true;
    dir       = "keepassxc";
    cloneFrom = "git@github.com:Unigurd/keepassxc";
  };








  home.stateVersion = "23.11";
}
