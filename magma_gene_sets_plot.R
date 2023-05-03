#!/usr/bin/env Rscript 

library(dplyr)
library(ggplot2)

args = commandArgs(trailingOnly = TRUE)

prefix = "iPSYCH2015_EUR_"
suffix = "_C5_GO.gsa.out"

results = read.table(paste0(prefix, "xDx", suffix), header = T)
results = results %>%
    arrange(P) %>%
    head(10) %>%
    select(FULL_NAME, BETA, BETA_STD, P) %>%
    mutate(TRAIT = "xDx") %>% 
    mutate(GWAS = "Case vs Cohort")


for (trait in c("ADHD", "ANO", "AUT", "BIP", "MDD", "SCZ")) {
    file      = read.table(paste0(prefix, trait, suffix), header = T)
    file_cc   = read.table(paste0(prefix, trait, "_CC", suffix), header = T)
    top_10    = file %>% arrange(P) %>% head(10) %>% select(FULL_NAME)
    top_10_cc = file_cc %>% arrange(P) %>% head(10) %>% select(FULL_NAME)
    to_subset = rbind(top_10, top_10_cc) %>% unique()
    file      = inner_join(to_subset, file, by = c("FULL_NAME")) %>%
        select(FULL_NAME, BETA, BETA_STD, P) %>%
        mutate(GWAS = "Case vs Cohort")
    file_cc   = inner_join(to_subset, file_cc, by = c("FULL_NAME")) %>%
        select(FULL_NAME, BETA, BETA_STD, P) %>%
        mutate(GWAS = "Case vs Other Cases")
    merged    = rbind(file, file_cc) %>% mutate(TRAIT = trait)
    results   = rbind(results, merged)
}

for (trait in c("ADHD_AUT", "ADHD_ANO", "ADHD_BIP", "ADHD_MDD", "ADHD_SCZ",
                "ANO_AUT", "ANO_BIP", "ANO_MDD", "ANO_SCZ",
                "AUT_BIP", "AUT_MDD", "AUT_SCZ",
                "BIP_MDD", "BIP_SCZ",
                "MDD_SCZ")) {
    file = read.table(paste0(prefix, trait, "_CC", suffix), header = T)
    file = file %>%
        arrange(P) %>%
        head(10) %>%
        select(FULL_NAME, BETA, BETA_STD, P) %>%
        mutate(TRAIT = trait) %>% 
        mutate(GWAS = "Case vs Case Pairwise")
    results   = rbind(results, file)
}

png(args[1], res = 300, width = 12, height = 12, units = "in")

ggplot(results, aes(y = FULL_NAME, x = -log10(P), fill = GWAS)) + 
    geom_bar() +
    theme_classic() + 
    facet_wrap(TRAIT ~ .) + 
    scale_fill_gradient2(low = "blue", mid = "white", high = "red")

dev.off()