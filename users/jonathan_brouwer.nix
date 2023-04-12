{ pkgs, ... }: {
  users.extraUsers.jonathan-brouwer = {
    isNormalUser = true;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFP6UDiX8vb4rHV+8Zwaozh8dnCAsPM+fe/4BEfC/xyV jonathantbrouwer@gmail.com"
    ];

    extraGroups = [ ];
  };
}
