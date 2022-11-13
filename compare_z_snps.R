#!/usr/bin/env Rscript

require(dplyr)
require(ggplot2)
require(data.table)

args = commandArgs(trailingOnly = TRUE)

index_snps            = fread(args[1], header = F)
colnames(index_snps)  = c("CHR", "START", "END", "SNP", "BP", "P")
eur_assoc             = fread(args[2], header = T)
eur_assoc             = eur_assoc %>% mutate(Z_EUR = BETA/SE)
eur_assoc_index       = semi_join(eur_assoc, index_snps, by = c("SNP")) %>% 
    select(SNP, Z_EUR)
eur_unrel_assoc       = fread(args[3], header = T)
eur_unrel_assoc       = eur_unrel_assoc %>% mutate(Z_EUR_UNREL = BETA/SE)
eur_unrel_assoc_index = semi_join(eur_unrel_assoc, index_snps, by = c("SNP")) %>%
    select(SNP, Z_EUR_UNREL)
z_comp = inner_join(eur_assoc_index, eur_unrel_assoc_index, by = c("SNP"))

png(args[3], res = 300, width = 8, height = 8, units = "in")

ggplot(z_comp, aes(x = Z_EUR, y = Z_EUR_UNREL)) + 
    geom_point() + 
    geom_abline(slope = 1, color = "blue") + 
    theme_bw() 

dev.off()