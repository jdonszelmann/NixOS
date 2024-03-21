{ pkgs, lib, ... }:
with builtins;
with lib.attrsets;
let
  aliases = {
    "p" = "python -i ${
        pkgs.writeText "init.py" ''
          from math import *;
          # import numpy as np
        ''
      } ";
    "s" = "systemctl";
    "j" = "journalctl";
    "ju" = "journalctl -u";
    "jfu" = "journalctl -fu";
    "open" = "xdg-open";
    "clip" = "wl-copy";
    # TODO: use jetbrains as merge tool?
    "git" = "${
        pkgs.writeShellScriptBin "git_mergetool" ''
          SEARCH="CONFLICT"
          OUTPUT=$(git "$@" 2>&1 | tee /dev/tty)
          if `echo ''${OUTPUT} | grep -i "''${SEARCH}" 1>/dev/null 2>&1`
          then
            git mergetool
          fi
        ''
      }/bin/git_mergetool";
  };
  # extracting any compressed format
  extract = ''
    extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.zst)   tar --zstd xf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       ${pkgs.unzip}/bin/unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *.tar.xz)    tar xJf $1     ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         cho "'$1' is not a valid file"
     fi
    }
  '';
in {
  # Setup ZSH to use grml config
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
      export FZF_DEFAULT_COMMAND="${pkgs.ripgrep}/bin/rg --files --follow"
      source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
      source "${pkgs.fzf}/share/fzf/completion.zsh"
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
      eval "$(${pkgs.atuin}/bin/atuin init zsh)"

      ${extract}

      ${foldl' (a: b: a + "\n" + b) ""
      (mapAttrsToList (name: value: ''alias ${name}="${value}"'') aliases)}
    '';
    # otherwise it'll override the grml prompt
    promptInit = "";
  };
  environment.pathsToLink = [ "/share/zsh" ];

}
