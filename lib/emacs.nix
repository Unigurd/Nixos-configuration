pkgs: let
  package = (pkgs.emacsPackagesFor pkgs.emacs30).emacsWithPackages (
    epkgs:
      with epkgs; [
        # ace
        ace-jump-mode
        ace-window
        # completion and stuff
        vertico
        orderless
        corfu
        embark
        marginalia
        # evil
        # These are not used because evil fails to native-compile
        # evil evil-paredit
        # Lisp
        geiser
        geiser-guile
        slime
        # Git
        magit
        git-timemachine
        # highlighting
        highlight-indent-guides
        rainbow-delimiters
        smart-mode-line
        symbol-overlay
        # undo
        vundo
        undo-fu-session
        # various
        flycheck
        gcmh
        auctex
        arduino-mode
        ediprolog
        haskell-mode
        nix-mode
        font-lock-studio
        paredit
        eglot
        hydra
        fold-dwim
        eros
        casual
        format-all
        envrc
        python-pytest
        # tree-sitter
        treesit-grammars.with-all-grammars
        treesit-auto
        markdown-ts-mode
        # inspector
        inspector
        tree-inspector
      ]
  );
  module = {
    pkgs,
    config,
    lib,
    ...
  }: {
    config = {
      home.packages = with pkgs; [
        package
        nodejs # Needed for the emacs copilot package
        scowl # Needed to make emacs' icomplete work
        file # Needed for emacs' dired-show-file-type
        texlive.combined.scheme-full
        ghostscript # pdf2dsc from this package is used for `preview-latex` in emacs
        nil
        alejandra
      ];
    };
  };
in {
  inherit package module;
}
