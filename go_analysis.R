#!/usr/bin/env Rscript

library(dplyr)
library(gprofiler2)

args = commandArgs(trailingOnly = TRUE)

genes = read.table(args[1], header = TRUE)
genes = genes %>% arrange(desc(abs(ZSTAT)))
gostres <- gost(query = genes$GENE, 
                organism = "hsapiens", 
                ordered_query = TRUE, 
                significant = TRUE, 
                user_threshold = 0.05, 
                correction_method = "fdr", 
                sources = c("GO", "KEGG", "REAC", "TF", "MIRNA", 
                            "HPA", "CORUM", "HP", "WP"))
write.table(gostres$result,
            paste0(args[2], "_GOResults.txt"), 
            sep = "\t", 
            row.names = F,
            quote = F)
png(paste0(args[2], ".png"), width = 10, height = 8, units = "in", res = 300)
gostplot(multi_gostres2, capped = FALSE, interactive = FALSE)
dev.off()