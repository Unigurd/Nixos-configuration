{ config, pkgs, inputs, ...}:

{

  imports = [ ../lib/git-sync.nix ../lib/firefox.nix];

  home.file = {
    ".bashrc".source = ../dotfiles/.bashrc;
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".Xresources".source = ../dotfiles/.Xresources;
    ".config/i3/config".source = ../dotfiles/.config/i3/config;
    ".config/tmux/tmux.conf".source = ../dotfiles/.config/tmux/tmux.conf;
    ".emacs.d/tree-sitter".source ="${pkgs.emacsPackages.treesit-grammars.with-all-grammars}/lib";
  };

  programs.git = {
    enable = true;
    userEmail = "sson@baselifescience.com";
  };

  home.packages = with pkgs; [
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
