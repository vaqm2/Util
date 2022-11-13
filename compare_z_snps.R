#!/usr/bin/env Rscript

require(dplyr)
require(ggplot2)
require(data.table)

traits = c("xDx", "ADHD", "ANO", "AUT", "BIP", "MDD", "SCZ", 
           "ADHD_CC", "ANO_CC", "AUT_CC", "BIP_CC", "MDD_CC", "SCZ_CC")

base_dir = "/faststorage/jail/project/cross_disorder_2/people/vivapp/"

z_comp = data.table(SNP = character(), 
                    Z_EUR = numeric(), 
                    Z_EUR_UNREL = numeric(), 
                    MAF = numeric())
for (i in traits) {
index_snps = fread(paste0(base_dir, "CLUMP/iPSYCH2015_EUR_", i, ".indexSNPs.txt"), header = F)
colnames(index_snps) = c("CHR", "START", "END", "SNP", "BP", "P")
eur_assoc = fread(paste0(base_dir, "SAIGE_MLM/iPSYCH2015_EUR_", i, "_META_1.tbl"), header = T)
eur_assoc = eur_assoc %>% 
    mutate(Z_EUR = Effect/StdErr) %>% 
    mutate(MAF = ifelse(Freq1 <= 0.5, Freq1, 1 - Freq1)) %>% 
    rename(SNP = MarkerName) %>%
    select(SNP, MAF, Z_EUR)
eur_assoc_index = semi_join(eur_assoc, index_snps, by = c("SNP"))
eur_unrel_assoc = fread(args[3], header = T)
eur_unrel_assoc = eur_unrel_assoc %>% 
    mutate(Z_EUR_UNREL = Effect/StdErr) %>% 
    mutate(MAF = ifelse(Freq1 <= 0.5, Freq1, 1 - Freq1)) %>% 
    rename(SNP = MarkerName) %>%
    select(SNP, MAF, Z_EUR_UNREL)
eur_unrel_assoc_index = semi_join(eur_unrel_assoc, index_snps, by = c("SNP"))
z_comp_tmp = inner_join(eur_assoc_index, eur_unrel_assoc_index, by = c("SNP"))
z_comp = rbind(z_comp, z_comp_tmp)
}

z_comp %>% mutate(VarType = ifelse(MAF <= 0.05, "RARE", "COMMON"))

png("iPSYCH2015_EUR_vs_EUR_UNREL_Zscore.png", 
    res = 300, 
    width = 8, 
    height = 8, 
    units = "in")

ggplot(z_comp, aes(x = Z_EUR, y = Z_EUR_UNREL, color = VarType)) + 
    geom_point() + 
    geom_abline(slope = 1, lty = 2) + 
    theme_bw() +
    scale_color_manual(values = c("red", "blue"))

dev.off()