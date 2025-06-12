{
  config,
  pkgs,
  inputs,
  self,
  ...
}: {
  imports = [
    ../lib/git-sync.nix
    ../lib/firefox.nix
    self.nixosModules.x86_64-linux.gurd-battery-warning
    (import ../lib/emacs.nix pkgs).module
  ];

  gurd.battery-warning.enable = true;

  home.file = {
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".Xresources".source = ../dotfiles/.Xresources;
    ".config/i3/config".source = ../dotfiles/.config/i3/config;
    ".config/tmux/tmux.conf".source = ../dotfiles/.config/tmux/tmux.conf;
  };

  programs.git = {
    enable = true;
    userEmail = "Sigurddam@hotmail.com";
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    initExtra = "source ${../dotfiles/.bashrc}";
  };

  home.packages = with pkgs; [
    evince
    inputs.bash-utils.packages."${pkgs.system}".label
    inputs.bash-utils.packages."${pkgs.system}".note
    jq
    unzip
    binutils
    pulseaudio
    entr
    (import ../lib/filewatch.nix pkgs)
    scrot
  ];

  gurd.git-sync.keepassxc = {
    enable = true;
    dir = "keepassxc";
    cloneFrom = "git@github.com:Unigurd/keepassxc";
  };

  home.stateVersion = "23.11";
}
