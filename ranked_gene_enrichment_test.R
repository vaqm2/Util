#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = TRUE)

suppressPackageStartupMessages({
library(dplyr)
library(ggplot2)
library(data.table)
library(fgsea)})

magma_genes = fread("/Users/vapp0002/Desktop/iPSYCH2015_EUR_xDx.hgnc.out", header = T)
magma_genes = magma_genes %>% 
    arrange(desc(ZSTAT)) # Sort by MAGMA Z to get ranked list
ranked_genes = magma_genes$ZSTAT
names(ranked_genes) = magma_genes$GENE
go_resource = gmtPathways("/Users/vapp0002/Desktop/c5.all.v2023.1.Hs.symbols.gmt")
gsea_result = fgsea(pathways = go_resource,
                    stats = ranked_genes,
                    minSize = 15,
                    maxSize = 500,
                    nperm = 10000) %>%
    as.data.frame() %>%
    arrange(desc(padj))

# Select independent pathways 

concise_pathways = collapsePathways(as.data.table(gsea_result),
                                    pathways = go_resource,
                                    stats = ranked_genes)
concise_pathways = concise_pathways$mainPathways %>% as.data.frame()
colnames(concise_pathways) = c("pathway")
gsea_concise_result = inner_join(gsea_result, 
                                 concise_pathways,
                                 by = c("pathway"))

fwrite(gsea_concise_result,
       args[3],
       sep = "\t",
       row.names = F,
       quote = F)