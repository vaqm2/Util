#!/usr/bin/env Rscript

library(dplyr)
library(ggplot2)
library(data.table)

args = commandArgs(trailingOnly = TRUE)

# Reading the MAGMA association results
association = fread(args[1], header = T)
head(association)
# total genes is the number tested for magma association
total_genes = nrow(association)

# Enriched genes are selected as the subset that passes FDR correction 
enriched_genes = association %>% 
    mutate(P_FDR = p.adjust(P, method = c("fdr"))) %>%
    filter(P_FDR <= 0.05)
num_enriched_genes = nrow(enriched_genes)

# Reading the dosage sensitivity gene lists
symbol_map = readxl::read_xlsx(args[2],
                               sheet = 1,
                               col_names = TRUE)
genes_x_dose = readxl::read_xlsx(args[2], 
                                 sheet = 2, 
                                 col_names = c("Gene", "Padj"))
genes_y_dose = readxl::read_xlsx(args[2], 
                                 sheet = 3, 
                                 col_names = c("Gene", "Padj"))
genes_xx_xy_dose = readxl::read_xlsx(args[2], 
                                     sheet = 4, 
                                     col_names = c("Gene", "MeanExp"))

# Dump genes with blanks in HGNC identifiers

symbol_map = symbol_map %>% 
    filter(Symbol != "") %>%
    select(Gene, Symbol)

# Restrict dose sensitivity genes to FDR adjusted P <= 0.05

genes_x_dose = genes_x_dose %>% filter(Padj <= 0.05)
genes_y_dose_sig = genes_y_dose %>% filter(Padj <= 0.05)

# Pick top 100 when no significance threshold available.

genes_xx_xy_dose = genes_xx_xy_dose %>% head(100)

# Intersect MAGMA associations and dosage sensitivity gene lists

genes_x_dose = inner_join(genes_x_dose, symbol_map, by = c("Gene")) %>% 
    select(-Gene) %>%
    rename(GENE = Symbol)
genes_y_dose = inner_join(genes_y_dose, symbol_map, by = c("Gene")) %>%
    select(-Gene) %>% 
    rename(GENE = Symbol)
genes_xx_xy_dose = inner_join(genes_xx_xy_dose, symbol_map, by = c("Gene")) %>%
    select(-Gene) %>%
    rename(GENE = Symbol)

# Count overlaps

x_dose_overlap = inner_join(enriched_genes, 
                            genes_x_dose, 
                            by = c("GENE")) %>%
    nrow()
y_dose_overlap = inner_join(enriched_genes, 
                            genes_y_dose, 
                            by = c("GENE")) %>%
    nrow()
xx_xy_dose_overlap = inner_join(enriched_genes, 
                                genes_xx_xy_dose, 
                                by = c("GENE")) %>%
    nrow()

# Hypergeometric test for enrichment of MAGMA associations in ranked dosage
# sensitivity gene lists

p_x_dose = phyper(q = x_dose_overlap - 1, 
       m = nrow(genes_x_dose),
       n = total_genes - nrow(genes_x_dose),
       k = num_enriched_genes,
       lower.tail = FALSE)

p_y_dose = phyper(q = y_dose_overlap - 1, 
                  m = nrow(genes_y_dose),
                  n = total_genes - nrow(genes_y_dose),
                  k = num_enriched_genes,
                  lower.tail = FALSE)

p_xx_xy_dose = phyper(q = xx_xy_dose_overlap - 1,
                      m = nrow(genes_x_dose),
                      n = total_genes - nrow(genes_x_dose),
                      k = num_enriched_genes,
                      lower.tail = FALSE)

print(paste(args[1], 
            "X:", p_x_dose, 
            "Y:", p_y_dose, 
            "XX-XY:", p_xx_xy_dose, 
            sep = " "))