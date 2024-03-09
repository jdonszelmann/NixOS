{ pkgs, inputs, ... }: rec {
  programs.vscode = {
    enable = true;
    extensions =
      with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
        rust-lang.rust-analyzer
        jnoortheen.nix-ide
        vscodevim.vim
      ];

    userSettings = {
      "editor.mouseWheelZoom" = true;
      "editor.formatOnSave" = true;
      "vim.useSystemClipboard" = true;
      "window.zoomLevel" = 1;
      "git.openRepositoryInParentFolders" = "never";
      "nix.formatterPath" = "nixfmt";
    };
  };
}
