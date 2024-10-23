{ config, pkgs, inputs, ...}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sson";
  home.homeDirectory = "/home/sson";

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
    ((emacsPackagesFor emacs30).emacsWithPackages (
      epkgs: with epkgs; [
        # ace
        ace-jump-mode ace-window
        # casual
        # casual-symbol-overlay missing for some
        # reason. Install from melpa instead.
        casual-dired casual-info casual-ibuffer
        casual-isearch casual-re-builder
        # completion and stuff
        vertico orderless corfu embark marginalia
        # evil
        # These are not used because evil fails to native-compile
        # evil evil-paredit
        # Lisp
        geiser geiser-guile slime
        # Git
        magit git-timemachine
        # highlighting
        highlight-indent-guides rainbow-delimiters smart-mode-line
        symbol-overlay
        # undo
        vundo undo-fu-session
        # various
        flycheck gcmh auctex arduino-mode ediprolog haskell-mode
        nix-mode font-lock-studio treesit-auto paredit eglot hydra
      ]
    ))

    python312Packages.python-lsp-server
    nil
    nodejs  # Needed for the emacs copilot package

  ];





  # This value determines the Home Manager release that your configuration is
  # compatible with.
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
