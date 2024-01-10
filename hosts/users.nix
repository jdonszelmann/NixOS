{ pkgs, ... }: {
  users.extraUsers.vivian = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKME+A5zu36tMIsY+PBoboizgAzt6xReUNrKRBkxvl3i vivian@null"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8llUcEBHsLqotFZc++LNP2fjItuuzeUsu5ObXecYNj vivian@eevee"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBhJAp7NWlHgwDYd2z6VNROy5RkeZHRINFLsFvwT4b3 vivian@bastion"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMMbdjysLnmwJD5Fs/SjBPstdIQNUxy8zFHP0GlhHMJB vivian@bastion"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIfooZjMWXvXZu1ReOEACDZ0TMb2WJRBSOLlWE8y6fUh vivian@aoife"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMTCUjDbDjAiEKbKmLPavuYM0wJIBdjgytLsg1uWuGc vivian@nord"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIM3TqXaApX2JZsgfZd7PKVFMecDgqTHKibpSzgdXNpYAAAAABHNzaDo= solov2-le"
    ];
  };

  users.extraUsers.jonathan = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # ori (lenovo laptop/desktop)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIET69oniNUA2nJV5+GxQ6XuK+vQbO8Uhtgrp1TrmiXVi jonathan@ori"

      # bastion (arch server)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHJT6QJcxhUKjvHBv3Bd1rugyfAFUpxIe9cu1Frw3ylL jonathan@bastion"

      # fili (server)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC0pmCsQeMMJ0r3o/XN7Zw8YFa9OEqrL3ikoGTK0OUY6 jonathan@fili"

      # kili (tudelft laptop)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAXOTU6E06zjK/zkzlSPhTG35PoNRYgTCStEPUYyjeE jonathan@kili"

      # nori hp tudelft laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSCuEu1kFg8mAgpOuYZ/IH2Ur7LQP7sQrDjcPmerkSx jonabent@gmail.com"
    ];
    # Make me admin
    extraGroups = [ "systemd-journal" "wheel" "networkmanager" "libvirtd" "dialout" "storage" "syncthing" "jellyfin" ];
  };
  users.extraUsers.laura = {
    isNormalUser = true;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIlFUUXbwOkhNUjoA6zueTdRuaylgpgFqSe/xWGK9zb laura@zmeura"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVkk9/80askWhInQk03JMntF6SThAYkFZNm+lIGt4E7 laura@mura"
    ];
  };
  users.extraUsers.julia = {
    isNormalUser = true;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMgLEF93nnp7ZKo3/YEbYHg3BqmgA7X2tcIj0Y50DA2U GitLab Assignment"
    ];

    # minecraft = {
    #   username = "Vlamonster";
    #   uuid = "99a4315a-24d8-4f82-b9ab-65097957774c";
    # };
  };
  users.extraUsers.jonathan-brouwer = {
    isNormalUser = true;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFP6UDiX8vb4rHV+8Zwaozh8dnCAsPM+fe/4BEfC/xyV jonathantbrouwer@gmail.com"
    ];

    # minecraft = {
    #   username = "Bammerbom";
    #   uuid = "27d51a02-1cec-49fa-8afa-4a6aff0e5b0a";
    # };
  };

}
