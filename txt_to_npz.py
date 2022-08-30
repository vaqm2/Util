#!/usr/bin/env python

import sys
import numpy as np

ld_file = open(sys.argv[1], "r")
print("Reading LD file" + sys.argv[1] + "..")
ld_matrix = ld_file.read(sys.argv[1])
print("Writing to .npz" + sys.argv[2] + "..")
np.savez(sys.argv[2], ld_matrix)