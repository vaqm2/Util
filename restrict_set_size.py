#!/usr/bin/env python

import sys
import pandas as pd

sets_df = pd.read_csv(sys.argv[1], sep = '\s+', header = None, names = ["SET", "GENE"])
gene_sets_10_500 = sets_df.drop_duplicates().groupby("SET").filter(lambda x: 10 <= len(x) <= 500)
gene_sets_10_500.to_csv(sys.argv[2], sep = '\t', header = None, index = False)