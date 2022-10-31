#!/usr/bin/env Rscript

library(dplyr)
library(data.table)

args = commandArgs(trailingOnly = TRUE)
assoc = fread(args[1], header = TRUE)
assoc = assoc %>% 
    mutate(Z = BETA/SE) %>% 
    select(SNP, CHR, BP, A1, A2, Z)

write.table(assoc, args[2], sep = " ", row.names = F, quote = F)
