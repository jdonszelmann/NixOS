{ pkgs, ... }: {
  users.extraUsers.jonathan = {
    # This account is intended for a non-system user.
    isNormalUser = true;

    # My default shell
    shell = pkgs.zsh;

    # My SSH keys.
    openssh.authorizedKeys.keys = [
      # ori
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIET69oniNUA2nJV5+GxQ6XuK+vQbO8Uhtgrp1TrmiXVi jonathan@ori"
      # bastion
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHJT6QJcxhUKjvHBv3Bd1rugyfAFUpxIe9cu1Frw3ylL jonathan@bastion"
      # fili
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC0pmCsQeMMJ0r3o/XN7Zw8YFa9OEqrL3ikoGTK0OUY6 jonathan@fili"
    ];

    # Make me admin
    extraGroups = [ "systemd-journal" "wheel" "networkmanager" "libvirtd" "dialout" "storage" ];
  };
}
