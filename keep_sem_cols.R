#!/usr/bin/env Rscript

require(dplyr)
require(data.table)

args = commandArgs(trailingOnly = TRUE)
file = fread(args[1], header = T)
file = file %>% select(CHR, POS, RSID, A1, A2, Z, P, SE, INFO)
file = file %>% rename(SNP = RSID)
write.table(file, args[2], sep = " ", row.names = F, quote = F)