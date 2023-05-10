#!/usr/bin/env Rscript

library(dplyr)
library(ggplot2)
library(data.table)

test_hyper = function(x_df, y_df, map_df) {
    dose_sensitive = inner_join(x_df, map_df) %>% 
        filter(P_ADJ <= 0.05)
    n_dose_sensitive = nrow(dose_sensitive)
    enriched = y_df %>% 
        mutate(P_FDR = p.adjust(P, method = c("fdr"))) %>%
        filter(P_FDR <= 0.05)
    n_enriched = nrow(enriched)
    n_overlap = inner_join(n_dose_sensitive, enriched) %>% nrow()
    n_total = nrow(y_df)
    p_test = phyper(q = n_overlap - 1,
                    m = n_dose_sensitive,
                    n = n_total - n_dose_sensitive,
                    k = n_enriched)
    return(p_test)
}

args = commandArgs(trailingOnly = TRUE)

# Reading the MAGMA association results
association = fread(args[1], header = T)

# Reading the dosage sensitivity gene lists
symbol_map = readxl::read_xlsx(args[2],
                               sheet = 1,
                               skip = 1,
                               col_names = c("ENSEMBL", "CHR", "GENE"))
genes_x_dose = readxl::read_xlsx(args[2], 
                                 sheet = 2,
                                 skip = 1,
                                 col_names = c("ENSEMBL", "P_ADJ"))
genes_y_dose = readxl::read_xlsx(args[2], 
                                 sheet = 3,
                                 skip = 1,
                                 col_names = c("ENSEMBL", "P_ADJ"))
genes_xx_xy_dose = readxl::read_xlsx(args[2], 
                                     sheet = 4,
                                     skip = 1,
                                     col_names = c("ENSEMBL", "MEAN_EXP"))

p_x = test_hyper(genes_x_dose, association, symbol_map)
p_y = test_hyper(genes_y_dose, association, symbol_map)
p_xx_xy = test_hyper(genes_xx_xy_dose, association, symbol_map)
pheno = gsub("^iPSYCH2015_EUR_", "", args[1])
pheno = gsub("\.hgnc\.out$", "", pheno)

print(paste(pheno, "X :", p_x, sep = " "))
print(paste(pheno, "Y :", p_y, sep = " "))
print(paste(pheno, "XX XY :", p_xx_xy, sep = " "))