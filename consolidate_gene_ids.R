#!/usr/bin/env Rscript

library(dplyr)

base_data_dir = "/faststorage/project/xdx2/data/magma"
load(paste0(base_data_dir, "/H-Magma/geneAnno_allgenes.rda"))
geneAnno1 %>% 
    filter(hgnc_symbol != "") %>% 
    select(ensembl_gene_id, hgnc_symbol)

for (file in list.files(pattern = "*.txt")) {
    print(paste0("Processing", " ", file, ".."))
    out_file = paste0(gsub(".txt$", "", file), ".sets.txt")
    network = read.table(file, header = F)
    colnames(network) = c("Network", "ensembl_gene_id")
    network = inner_join(network, geneAnno1, by = c("ensembl_gene_id")) %>%
        select(-ensembl_gene_id)
    write.table(network, out_file, row.names = F, col.names = F, 
                sep = "\t", quote = F)
    print(paste0("Wrote", " ", out_file, "!"))
}