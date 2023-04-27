#!/usr/bin/env Rscript

library(dplyr)
library(gprofiler2)

args = commandArgs(trailingOnly = TRUE)
files = list.files(path = getwd(), pattern = "*.genes.out")
out_file = paste0(args[1], "_Enrichments.txt")
file.create(out_file)

write(paste("SOURCE", "TERM", "TERM_SIZE", "INTERSECTION_SIZE", "P_FDR", "TEST", 
            sep = "\t"), 
      out_file,
      append = TRUE)

for (file in files) {
    genes = read.table(file, header = TRUE)
    genes_selected = genes %>%
        arrange(desc(abs(ZSTAT))) %>%
        head(500) %>%
        select(GENE)
    genes_background = genes %>% 
        select(GENE) %>% 
        sample()
    gost_out = gost(query = genes_selected$GENE, 
                    organism = "hsapiens", 
                    ordered_query = TRUE, 
                    significant = TRUE,
                    user_threshold = 0.05, 
                    correction_method = "fdr",
                    custom_bg = genes_background$GENE,
                    evcodes = FALSE,
                    sources = c("GO"))
    if(!is.NULL(gost_out$result)) {
        gost_result = gost_out$result %>% 
            arrange(p_value) %>%
            as.data.frame() %>%
            filter(term_size >= 15 & term_size <= 600 & intersection_size >= 5) %>%
            select(source, term_name, term_size, intersection_size, p_value) %>% 
            mutate(query = args[1])
    
        write.table(gost_result,
                    out_file, 
                    sep = "\t", 
                    row.names = F,
                    col.names = F,
                    quote = F,
                    append = TRUE)
    }
}