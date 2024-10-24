pkgs:
let
  emacs = (pkgs.emacsPackagesFor pkgs.emacs30).emacsWithPackages (
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
      # inspector
      inspector tree-inspector
    ]
  );
  # Add nodejs, scowl and file to PATH
  # nodejs is needed for the emacs copilot package
  # scowl is needed to make emacs' icomplete work
  # file is needed for emacs' dired-show-file-type
  wrapper = pkgs.stdenv.mkDerivation {
    name = "sigurds-wrapped-emacs";
    buildInputs = [ emacs pkgs.makeWrapper ];
    phases = [ "installPhase "];
    installPhase = ''
    mkdir -p $out/bin
    makeWrapper "${emacs}/bin/emacs" "$out/bin/emacs" --prefix PATH : ${pkgs.nodejs}/bin --prefix PATH : ${pkgs.scowl}/bin --prefix PATH : ${pkgs.file}/bin
    '';
  };
in wrapper
