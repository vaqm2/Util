#!/usr/bin/env Rscript

library(dplyr)

args = commandArgs(trailingOnly = TRUE)

genes = read.table("/faststorage/jail/project/xdx2/magma/NCBI37.3.gene.loc", 
                   header = F)
colnames(genes) = c("CODE", "CHR", "START", "END", "STRAND", "GENE")
genes = genes %>% select(CODE, GENE)
result = read.table(args[1], header = T)
result = result %>% rename(CODE = GENE)
result = inner_join(genes, result, by = c("CODE")) %>% select(-CODE)

write.table(result, 
            args[2], 
            row.names = F, 
            col.names = F, 
            quote = F, 
            sep = "\t")