#!/usr/bin/env Rscript 

library(dplyr)
library(janitor)
library(reshape2)

genes = readxl::read_xlsx("/Users/vapp0002/Downloads/KonradPaper_GeneLists.xlsx",
                          sheet = 1,
                          col_names = TRUE)
modules = readxl::read_xlsx("/Users/vapp0002/Downloads/KonradPaper_GeneLists.xlsx",
                            sheet = 2,
                            skip = 1,
                            col_names = c("SET", "MODULE"))
modules$SET = make_clean_names(modules$SET, allow_dupes = TRUE) 
modules$MODULE = make_clean_names(modules$MODULE, allow_dupes = TRUE) 

gene_sets = genes %>% 
    clean_names() %>%
    select(-entrez_id, -ensemblgene) %>% 
    melt(id.vars = c("gene_symbol")) %>% 
    filter(value == TRUE) %>% 
    select(variable, gene_symbol) %>%
    rename(SET = variable)

wgcna = genes %>% 
    clean_names %>% 
    select(wgcna_modules, gene_symbol)
    

meta_modules = inner_join(gene_sets, modules, by = c("SET")) %>%
    select(MODULE, gene_symbol)

write.table(wgcna, 
            "Konrad_Raznahan_WGCNA_Modules.txt", 
            sep = "\t", 
            row.names = F,
            col.names = F,
            quote = F)

write.table(gene_sets, 
            "Konrad_Raznahan_Sets.txt", 
            sep = "\t", 
            row.names = F,
            col.names = F,
            quote = F)

write.table(meta_modules, 
            "Konrad_Raznahan_Modules.txt", 
            sep = "\t", 
            row.names = F,
            col.names = F,
            quote = F)