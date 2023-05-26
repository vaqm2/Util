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
gsea_result = fgseaMultilevel(pathways = go_resource,
                    stats = ranked_genes,
                    minSize = 15,
                    maxSize = 2000,
                    eps = 0,
                    nPermSimple = 100000) %>%
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

fwrite(gsea_result, 
       paste0(args[3], "_GSEA_Results.txt"),
       sep = "\t",
       row.names = F,
       quote = F)

fwrite(gsea_concise_result,
       paste0(args[3], "_GSEA_Concise_Results.txt"),
       sep = "\t",
       row.names = F,
       quote = F)