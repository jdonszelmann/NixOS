{ pkgs, ... }: {
  calc = "${pkgs.python313}/bin/python -i ${
      pkgs.writeText "init.py" ''
        from math import *;
        # import numpy as np
      ''
    } ";
}
