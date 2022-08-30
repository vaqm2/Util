#!/usr/bin/env python

import sys
import numpy as np

print("Reading LD file" + sys.argv[1] + "..")
with open(sys.argv[1], "r") as ld_file:
    ld_matrix = ld_file.readlines()

print("Writing to .npz" + sys.argv[2] + "..")
np.savez(sys.argv[2], ld_matrix)