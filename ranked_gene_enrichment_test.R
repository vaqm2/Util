#!/usr/bin/env Rscript

library(dplyr)
library(ggplot2)
library(data.table)

args = commandArgs(trailingOnly = TRUE)
association = fread(args[1], header = T)
enriched_genes = association %>% 
    mutate(P_FDR = p.adjust(P, method = c("fdr"))) %>%
    filter(P_FDR <= 0.05) %>%
    arrange(desc(abs(ZSTAT)))
genes_xls = args[2]

# Read input lists from xls

symbol_map = readxl::read_xlsx(args[2],
                               sheet = 1,
                               header = TRUE)
genes_x_dose = readxl::read_xlsx(args[2], 
                                 sheet = 2, 
                                 header = TRUE)
genes_y_dose = readxl::read_xlsx(args[2], 
                                 sheet = 3, 
                                 header = TRUE)
genes_xx_xy_dose = readxl::read_xlsx(args[2], 
                                     sheet = 4, 
                                     header = TRUE)

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
       n = nrow(symbol_map) - nrow(genes_x_dose),
       k = length(enriched_genes),
       lower.tail = FALSE)

p_y_dose = phyper(q = y_dose_overlap - 1, 
                  m = nrow(genes_y_dose),
                  n = nrow(symbol_map) - nrow(genes_y_dose),
                  k = length(enriched_genes),
                  lower.tail = FALSE)

p_xx_xy_dose = phyper(q = xx_xy_dose_overlap - 1,
                      m = nrow(genes_x_dose),
                      n = nrow(symbol_map) - nrow(genes_x_dose),
                      k = length(enriched_genes),
                      lower.tail = FALSE)

print(paste0("X dose enrichment: ", p_x_dose))
print(paste0("Y dose enrichment: ", p_y_dose))
print(paste0("XX XY dose enrichment: ", p_xx_xy_dose))