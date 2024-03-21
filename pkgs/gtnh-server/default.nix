{ pkgs, lib, fetchzip, ... }:
let
  server-files = fetchzip {
    url =
      "http://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_2.5.1_Server_Java_8.zip";
    sha256 = "sVw6xTAqOck3aO6eM77dildSGR0TRb3e9XpgUPZYtT0=";
    stripRoot = false;
  };
in pkgs.stdenv.mkDerivation {
  pname = "gtnh-server";
  version = "2.5.1";
  src = server-files;

  installPhase = ''
    mkdir -p $out/bin
    cp -rv $src/* $out

    # put a fixed start script in the bin folder
    echo "#!${pkgs.bash}/bin/bash
    while true
    do
       ${pkgs.zulu8}/bin/java -XX:+UseStringDeduplication -XX:+UseCompressedOops -XX:+UseCodeCacheFlushing -Dfml.readTimeout=180 \$@ -jar $out/forge-1.7.10-10.13.4.1614-1.7.10-universal.jar nogui
        echo "If you want to completely stop the server process now, press Ctrl+C before the time is up!"
        echo "Rebooting in:"
        for i in 12 11 10 9 8 7 6 5 4 3 2 1
        do
            echo "\$i..."
            sleep 1
        done
        echo "Rebooting now!"
    done
    " > $out/bin/minecraft-server
    chmod +x $out/bin/minecraft-server

    # accept the eula
    rm $out/eula.txt
    echo 'eula=true' > $out/eula.txt
  '';
}

