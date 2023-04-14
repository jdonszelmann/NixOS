{ pkgs, ... }: {
  users.extraUsers.julia = {
    isNormalUser = true;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMgLEF93nnp7ZKo3/YEbYHg3BqmgA7X2tcIj0Y50DA2U GitLab Assignment"
    ];

    extraGroups = [ ];

    minecraft = {
      username = "Vlamonster";
      uuid = "99a4315a-24d8-4f82-b9ab-65097957774c";
    };
  };
}
