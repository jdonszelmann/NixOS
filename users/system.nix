# for server deployment

{ pkgs, ... }: {
  users.extraUsers.system = {
    isNormalUser = true;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5kxOOKkEsqBLx/b7wp//i8KZiodNOZu3EG3llxxwnH system@fili"
    ];

    extraGroups = [ "wheel" ];
  };
}
