#!/usr/bin/env Rscript

library(data.table, quietly = TRUE)
library(dplyr, quietly = TRUE)

args     = commandArgs(trailingOnly = TRUE)
assoc_df = fread(args[1], header = T)
assoc_df = assoc_df %>% 
    mutate(OR = exp(BETA)) %>% 
    arrange(CHR, BP)

write.table(assoc_df, args[2], sep = " ", row.names = F, quote = F)