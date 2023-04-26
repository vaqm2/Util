#!/usr/bin/env Rscript

library(dplyr)
library(gprofiler2)

args = commandArgs(trailingOnly = TRUE)

genes = read.table(args[1], header = TRUE)
genes = genes %>% arrange(desc(abs(ZSTAT)))
gost_out = gost(query = genes$GENE, 
                organism = "hsapiens", 
                ordered_query = TRUE, 
                significant = TRUE, 
                user_threshold = 0.05, 
                correction_method = "fdr", 
                sources = c("GO", "KEGG", "REAC", "TF", "MIRNA", 
                            "HPA", "CORUM", "HP", "WP"))
gost_result = gost_out$result %>% 
    select(-query) %>%
    mutate(query = args[2]) %>%
    filter(term_size >= 15 & term_size <= 600 & intersection_size >= 5) %>%
    arrange(p_value) %>%
    as.data.frame()
gost_result$parents = paste(gost_result$parents, collapse = ",")
gost_result$evidence_codes = paste(gost_result$evidence_codes, collapse = ",")

highlight = gost_result %>% head(10) %>% select(term_id)
    
write.table(gost_result,
            paste0(args[2], "_GOResults.txt"), 
            sep = "\t", 
            row.names = F,
            quote = F)
gost_plot = gostplot(gost_out, capped = FALSE, interactive = FALSE)
png(paste0(args[2], ".png"), width = 10, height = 8, units = "in", res = 300)
publish_gostplot(gost_plot, highlight_terms = highlight$term_id)
dev.off()