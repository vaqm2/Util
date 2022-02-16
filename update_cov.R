#!/usr/bin/env Rscript

require(dplyr)

args = commandArgs(trailingOnly = T)

cov           = args[1]
pcs           = args[2]
out           = args[3]
colnames(cov) = colnames(cov) %>% tolower()
colnames(pcs) = colnames(pcs) %>% tolower()
cov           = cov %>% select(fid, iid, age, sex)
cov_pcs       = inner_join(cov, pcs, by = c("fid", "iid"))

write.table(cov_pcs, out, row.names = F, quote = F, sep = " ")