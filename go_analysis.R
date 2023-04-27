#!/usr/bin/env Rscript

library(dplyr)
library(gprofiler2)
library(logr)

log_file = paste0(args[2], ".log")
log_open(log_file)

args = commandArgs(trailingOnly = TRUE)

genes = read.table(args[1], header = TRUE)
genes_associated = genes %>% 
    mutate(P_ADJ = p.adjust(P, method = c("fdr"))) %>%
    filter(P_ADJ < 0.1)
num_associated_genes = length(genes_associated)

log_print(paste0("Number of associated genes at FDR < 0.1: ", 
                 num_associated_genes))

if(num_associated_genes > 0) {
    genes_associated %>% 
        arrange(P_ADJ) %>% 
        select(GENE)
    log_print("Proceeding to pathway analysis..")
} else {
    log_print("No genes to test, quitting..!")
    stop()
}
genes_background = genes %>% 
    select(GENE) %>% 
    sample()
gost_out = gost(query = genes_associated$GENE, 
                organism = "hsapiens", 
                ordered_query = TRUE, 
                significant = TRUE,
                user_threshold = 0.05, 
                correction_method = "fdr",
                custom_bg = genes_background$GENE,
                evcodes = FALSE,
                sources = c("GO"))
gost_result = gost_out$result %>% 
    arrange(p_value) %>%
    as.data.frame() %>%
    select(-parents)

write.table(gost_result,
            paste0(args[2], "_Enrichments.txt"), 
            sep = "\t", 
            row.names = F,
            quote = F)

log_print("Finished!")
log_close()