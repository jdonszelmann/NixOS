_: {
  # nvidia; prime (amd+nvidia)
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # only works for turing and newer
    # actually breaks suspend too so disabled
    # powerManagement.enable = true;
    # powerManagement.finegrained = true;

    open = true;
    nvidiaSettings = true;

    prime = {
      amdgpuBusId = "PCI:1:0:0";
      nvidiaBusId = "PCI:5:0:0";

      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };
}
