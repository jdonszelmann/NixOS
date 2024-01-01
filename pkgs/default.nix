final: prev: {
  custom = {
    # garage_0_8_2 = (prev.callPackage ./garage { }).garage_0_8_2;
    # matrix-registration = prev.callPackage ./matrix-registration { };

    unbound = prev.unbound.override {
      withSystemd = true;
      withDoH = true;
      withDNSCrypt = true;
      withTFO = true;
    };
  };
}
