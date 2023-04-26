#!/usr/bin/env Rscript

library(dplyr)
library(gprofiler2)

args = commandArgs(trailingOnly = TRUE)

genes = read.table(args[1], header = TRUE)
gost_out = gost(query = genes$GENE, 
                organism = "hsapiens", 
                ordered_query = TRUE, 
                significant = TRUE,
                user_threshold = 0.05, 
                correction_method = "fdr", 
                sources = c("GO"))
gost_result = gost_out$result %>% 
    filter(term_size >= 15 & term_size <= 600 & intersection_size >= 5) %>%
    arrange(p_value) %>%
    as.data.frame() %>% 
    select(-parents, -evidence_codes)

write.table(gost_result,
            paste0(args[2], "_Enrichments.txt"), 
            sep = "\t", 
            row.names = F,
            quote = F)