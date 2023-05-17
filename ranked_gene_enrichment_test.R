#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = TRUE)

suppressPackageStartupMessages({
library(dplyr)
library(ggplot2)
library(data.table)
library(fgsea)})

magma_genes = fread(args[1], header = T)
magma_genes = magma_genes %>% 
    arrange(desc(ZSTAT)) # Sort by MAGMA Z to get ranked list
ranked_genes = magma_genes$ZSTAT
names(ranked_genes) = magma_genes$GENE
go_resource = gmtPathways(args[2])
gsea_result = fgsea(pathways = go_resouce,
                    stats = ranked_genes,
                    minSize = 15,
                    maxSize = 500,
                    nperm = 10000,
                    eps = 0.0) %>%
    as.data.frame() %>%
    arrange(desc(padj))

# Select independent pathways 

concise_pathways = collapsePathways(as.data.table(fgRes),
                                    pathways = go_resource,
                                    stats = ranked_genes)
gsea_concise_result = inner_join(gsea_result, 
                                 concise_pathways, 
                                 by.x = "pathway",
                                 by.y = "mainPathways")

fwrite(gsea_concise_result,
       args[3],
       sep = "\t",
       row.names = F,
       quote = F)