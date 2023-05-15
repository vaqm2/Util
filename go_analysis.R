#!/usr/bin/env Rscript

library(dplyr)
library(gprofiler2)

args = commandArgs(trailingOnly = TRUE)
files = list.files(path = getwd(), pattern = "*.genes.out")
out_file = paste0(args[1], "_Enrichments.txt")
file.create(out_file)

write(paste("query", 
            "significant", 
            "p_value",
            "term_size", 
            "query_size", 
            "intersection_size", 
            "precision",
            "recall",
            "term_id",
            "source",
            "term_name",
            "effective_domain_size",
            "source_order",
            "parents",
            "evidence_codes",
            sep = "\t"), 
      out_file,
      append = TRUE)

for (file in files) {
    test = gsub("^iPSYCH2015_EUR_", "", file)
    test = gsub("\\..*$", "", test)
    print(paste0("Processing", " ", file, "..."))
    genes = read.table(file, header = TRUE)
    genes_selected = genes %>%
        mutate(P_ADJ = p.adjust(P, method = c("fdr"))) %>%
        filter(P_ADJ <= 0.05) %>% 
        arrange(desc(abs(ZSTAT))) %>%
        select(GENE)
    gost_out = gost(query = genes_selected$GENE, 
                    organism = "hsapiens", 
                    ordered_query = TRUE, 
                    significant = TRUE,
                    user_threshold = 0.05, 
                    correction_method = "g_SCS",
                    evcodes = TRUE,
                    domain_scope = "annotated",
                    custon_bg = genes$GENE,
                    sources = c("GO", "KEGG"))
    if(!is.null(gost_out$result)) {
        gost_result = gost_out$result %>% 
            arrange(p_value) %>%
            as.data.frame() %>%
            filter(term_size >= 15 & term_size <= 600 & intersection_size >= 5)
        
        gost_result$query = test
    
        write.table(gost_result,
                    out_file, 
                    sep = "\t", 
                    row.names = F,
                    col.names = F,
                    quote = F,
                    append = TRUE)
    }
    print("Done!")
}