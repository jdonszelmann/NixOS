{ pkgs
, ...
}:
let
  server_files = fetchGit { url = "https://github.com/MrPixelized/pvpixel"; ref = "master"; rev = "162e995fa58791b427c1c3dfae13d5318c4b9b7d"; };

  server = pkgs.dockerTools.buildLayeredImage {
    name = "server";
    tag = "latest";
    fromImage = pkgs.dockerTools.pullImage {
      imageName = "ghcr.io/paradigmmc/mcman";
      imageDigest = "sha256:d2c3d070046c3f992b8865b41e198e4ce136730fade906ef1fb93469dcf62eee";
      sha256 = "0hk54x45h3kr25q34k8aa6llqs2sybjd9v9bzvwc53vkyxw6ihff";
      finalImageName = "ghcr.io/paradigmmc/mcman";
      finalImageTag = "latest";
    };

    contents = [ server_files pkgs.busybox pkgs.bash pkgs.temurin-jre-bin-17 ];
    config = {
      WorkingDir = "/server";
      User = "1000:1000";
      Cmd = [ "bash" "-c" "mcman build; echo 'eula=true' >eula.txt; sed 's/max-players=8/max-players=12/' server.properties > server.properties.1; mv server.properties.1 server.properties; rm start.sh; echo 'java --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -Dcom.mojang.eula.agree=true -Xmx12G -jar server.jar --nogui \"$@\"' > ./start.sh; chmod +x ./start.sh; ./start.sh <<< 'op jonay2000'" ];
    };
  };
in
{
  config.virtualisation.oci-containers.containers = {
    minecraft = {
      imageFile = server;
      image = "server:latest";
      ports = [ "0.0.0.0:25565:25565" ];
      volumes = [
      ];
    };
  };

}
