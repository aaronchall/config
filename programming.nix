{pkgs, lib, ...}:
{
  # run the emacs server daemon so starting emacs (as a client) is super fast:
  services.emacs = {
    enable = true;
    package = (with pkgs; (
      (emacsPackagesFor emacs-pgtk).emacsWithPackages (epkgs: with epkgs; [
          evil # evil-mode provides vim keybindings (but not in everything! but better than viper, the builtin vim keybindings)
          ess # Emacs Speaks Statistics (R and SAS)
          projectile # project management?
          neotree
          ob-rust # org-babel
          rust-mode
          ob-elm
          org # let's see if this satisfies the req's of ob-elm, company-org-block, and ox-reveal?
          elm-mode
          treesit-grammars.with-all-grammars
          #tree-sitter-langs
          company # means "complete any"
          # company-stan
          company-math
          company-jedi # python
          company-ghci # haskell
          #company-org-block # org block autocompletion?
          company-c-headers
          company-nixos-options
          company-native-complete
          helm
          flycheck
          magit
          lsp-mode
          evil-markdown
          htmlize
          ox-reveal
          zotero
          fira-code-mode
          doom-themes
          doom-modeline
          adwaita-dark-theme
          gnuplot
          gnuplot-mode
          lsp-pyright
        ]
      )
    ));
  };
  environment.systemPackages = let
    # aborted overide of haskell package versions to upgrade quarto's pandoc:
    myHaskellPackages = pkgs.haskellPackages.extend ( self: super: {
    });
    # need these for reuse by patchedQuarto:
    myRPackages = import ./RPackages.nix {inherit pkgs; };
    myPythonPackages = ps: with ps; [
      ollama # python lib to interface with ollama
      #stem # tor
      python-sat # commented to demo
#      jedi-language-server
#      pycosat
#      pillow
#      types-pillow
      requests
#      types-requests
#      beautifulsoup4
      guppy3 # get heap/memory layout info
#      pip
#      numpy
#      numpy-stl # stereolithography
#      scipy
#      mypy
#      flake8
#      pytest
#      coverage
#      cython
#      wheel
       jupyterlab
#      flax
#      pyspark
#      networkx
#      pygraphviz
#      pygame
#      #tensorflow
#      # tensorflow-datasets
#      #keras
#      # torchaudio
#    #   #jupyterlab_lsp # pypi says requires:
      pandas
      statsmodels
      ipython
      scikit-learn
      sympy
      #reticulate # doesn't exist
#    #tornado
#    #   flask
#    #   django
#    #   pympler
#    #   pyqtgraph
    ];
    patchedQuarto = (pkgs.quarto.override {
        extraPythonPackages = myPythonPackages;
        extraRPackages = myRPackages;
      }).overrideAttrs (oldAttrs: {
      postPatch = (oldAttrs.postPatch or "") + ''
        substituteInPlace bin/quarto.js \
          --replace-fail "syntax-highlighting" "highlight-style"
      '';
    });
  in with pkgs; [
    pandoc
    ## Programming languages and related utils
    gnumake
    entr # run commands when files change, ie: ls . | entr python -m main
    rlwrap # readline wrap?
    sbcl # Steel Bank Common Lisp (Cargegie Mellon)
    jdk21 # Java 21
    #android-studio-full
    #qemu-utils
    # jdk17
    #### C/C++ programming:
    valgrind
    #gcc # conflicts with clang, I prefer clang error messages
    gdb
    openmpi # not sure if this works with clang
    clang # conflicts with gcc...
    #### Oracle:
    oracle-instantclient
    #### Scala:
    spark
    sbt
    #hadoop # I think this is provided by spark because collisions

    #### Markdown and document processing:
    # dupe pandoc # written in Haskell, maybe this should be in console.nix?
    #### R command line environment, RPackages.nix because RStudio in gui.nix
    ##(rWrapper.override {packages = import ./RPackages.nix {inherit pkgs; }; })
    (rWrapper.override {packages = myRPackages ; })
    ##### Python:
    (python3.withPackages myPythonPackages)
    ## next generation of Rmarkdown for Python, Julia, R, and JS:
    patchedQuarto
    uv # replace pip and package your python stuff better?
    pyright # Python linting tools, uses nodejs, probably why here and not below.
    #### Haskell
    (myHaskellPackages.ghcWithPackages (pkgs: with pkgs; [
      cabal-install
      lens
      yesod-bin
      tasty
#      # intero # marked broken
      hlint        # req'd by haskell layer
      hspec
      #pandoc
#      apply-refact # req'd
      stylish-haskell # marked broken
      hasktags
      hoogle
#      # ghc-mod # marked broken
#      #haskell-lsp
#      #hie # not defined
      ihaskell # maybe { allowBroken = true; }
      Euterpea
    ]))
    #### Go:
    go
    #### Rust:
    rustc
    cargo
    rustfmt
    rust-script
    #### Node and Javascript:
    nodejs
    deno
    typescript
    typescript-language-server
  ] ++ (with elmPackages; [
    elm
    #elm-format
    elm-analyse # lint?
    #elm-coverage # removed? no longer available...
    elm-test
    elm-review
    elm-language-server
    elm-optimize-level-2
    elm-live # live reload
  ]) ++ [
    # do I need these?: 
    kubectl # kubernetes 
    kind # use docker containers for CI and testing?
    kubernetes-helm # scale kubernetes deployments?
    #docker # why?
    podman-desktop # replaces docker (why ?) do I need this in addition to enable above?
    openshift
    #minishift # discontinued upstream, use crc instead
    # Not using below because it requires NetworkManager
    #crc # manage local OpenShift 4.x cluster or Podman VM optimized for testing and development
    ansible
  ];
}
