#!/usr/bin/env Rscript

suppressPackageStartupMessages(require(dplyr))
suppressPackageStartupMessages(require(data.table))

args              = commandArgs(trailingOnly = TRUE)
assoc             = fread(args[1], header = T)
regions           = fread(args[2], header = F)
colnames(regions) = c("CHROMOSOME", "START", "END", "SNP", "BP", "P")
regions           = regions %>% select("SNP", "START", "END")
finemap_assoc     = right_join(assoc, regions, by = c("SNP")) %>%
    select(SNP, CHR, BP, START, END, A1, A2, MAF, BETA, SE, P, Q) %>%
    arrange(Q)

write.table(finemap_assoc, args[3], row.names = F, quote = F, sep = " ")