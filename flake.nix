{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, ... }: {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [];
        };
      };

      fili = {
        deployment = {
          targetHost = "jdonszelmann.nl";
          targetPort = 1234;
          targetUser = "root";
          tags = "fili";
        };
        time.timeZone = "Europe/Amsterdam";
        
        services.openssh.enable = true;
        services.openssh.permitRootLogin = "yes";

        environment.systemPackages = with pkgs; [
            vim
        ];

        system.stateVersion = "22.11"; 
      };
    };
  };
}
