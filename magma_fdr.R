#!/usr/bin/env Rscript 

library(dplyr)

args = commandArgs(trailingOnly = T)
files = list.files(path = getwd(), pattern = "*.genes.out")
file.create(args[1])
load("/faststorage/project/xdx2/data/magma/H-Magma/geneAnno_allgenes.rda") %>% 
geneAnno1 = geneAnno1 %>%    
    filter(gene_biotype == "protein_coding" & hgnc_symbol != "") %>% 
    select(hgnc_symbol, ensembl_gene_id)
genes = read.table("/faststorage/project/xdx2/data/magma/NCBI37.3.gene.loc",
                   header = F)
genes = genes %>% 
    select(V1, V6) %>% 
    rename(entrez_id = V1,
           hgnc_symbol = V2)

genes = genes %>% inner_join(geneAnno1, genes, by = c("hgnc_symbol")) %>% 
    rename(GENE = entrez_id)

write(paste("GENE", "ZSTAT", "P", "P_ADJ", "TEST", sep = "\t"), 
      args[1], 
      append = TRUE)

for (file in files) {
    print(paste("Processing", file, "....", sep = " "))
    association = read.table(file, header = T)
    association = inner_join(association, genes) %>% 
        select(-GENE, -hgnc_symbol) %>% 
        rename(GENE = ensembl_gene_id)
    test = gsub("^iPSYCH2015_EUR_", "", file)
    test = gsub("\\..*", "", test)
    association = association %>% 
        mutate(P_ADJ = p.adjust(P, method = c("fdr"))) %>%
        select(GENE, ZSTAT, P, P_ADJ) %>%
        mutate(TEST = test)
    
    write.table(association,
                args[1],
                row.names = F,
                col.names = F,
                quote = F,
                sep = "\t",
                append = TRUE)
}