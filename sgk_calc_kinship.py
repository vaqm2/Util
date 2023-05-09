#!/usr/bin/env python

import pandas as pd
import sgkit as sg
import numpy as np
import sys
import xarray as xr

ped = pd.read_csv(sys.argv[1], sep = "\s+")
ped_ds = xr.Dataset()
header = ["samples", "parents"]
ped_ds["sample_id"] = header[0], ped[["id"]].values.astype(str).ravel()
ped_ds["parent_id"] = header, ped[["fatherid", "motherid"]].values.astype(str)
kinship = sg.pedigree_kinship(ped_ds, allow_half_founders = True)
print(kinship["stat_pedigree_kinship"].values) 