pkgs:
(pkgs.emacsPackagesFor pkgs.emacs30).emacsWithPackages (
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
    nix-mode font-lock-studio paredit eglot hydra fold-dwim
    eros
    # tree-sitter
    treesit-grammars.with-all-grammars treesit-auto
  ]
)
