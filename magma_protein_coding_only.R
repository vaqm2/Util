#!/usr/bin/env Rscript

args = commandArgs(trailingOnly =  TRUE)

library(dplyr)

load("/faststorage/project/xdx2/data/magma/geneAnno_allgenes.rda")
geneAnno1 = geneAnno1 %>% 
    filter(gene_biotype == "protein_coding") %>% 
    select(ensembl_gene_id, hgnc_symbol)
colnames(geneAnno1) = c("ENSEMBL_ID", "GENE")
result = read.table(args[1], header = T)
result = result %>% rename(ENSEMBL_ID = GENE)
result = inner_join(result, geneAnno1, by = c("ENSEMBL_ID"))
write.table(result, args[2], row.names = F, quote = F, sep = " ")