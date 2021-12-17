#!/usr/bin/env Rscript

require(data.table)
require(dplyr)

args  = commandArgs(trailingOnly = TRUE)

assoc = fread(args[1], header = TRUE)
snps  = fread(args[2], header = FALSE)
out   = args[3]

colnames(snps) = c("SNP")
tag_assoc = inner_join(snps, assoc, by = c("SNP")) %>%
    arrange(CHR, BP)

write.table(tag_assoc, out, row.names = F, quote = F, sep= " ")