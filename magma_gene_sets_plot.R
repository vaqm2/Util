#!/usr/bin/env Rscript 

library(dplyr)
library(ggplot2)
library(scales)

args = commandArgs(trailingOnly = TRUE)

prefix = "iPSYCH2015_EUR_"
suffix = "_C5_GO.gsa.out"

xdx = read.table(paste0(prefix, "xDx", suffix), header = T)
xdx = xdx %>%
    arrange(P) %>%
    head(10) %>%
    select(FULL_NAME, BETA, BETA_STD, P) %>%
    mutate(TRAIT = "xDx") %>% 
    mutate(GWAS = "Case vs Cohort")
xdx$FULL_NAME = gsub("_", " ", xdx$FULL_NAME)

case_case = xdx[FALSE,]
pairwise  = xdx[FALSE,]

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
    case_case = rbind(case_case, merged)
}

case_case$FULL_NAME = gsub("_", " ", case_case$FULL_NAME)


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
    pairwise = rbind(pairwise, file)
}

pairwise$FULL_NAME = gsub("_", " ", pairwise$FULL_NAME)

png(paste0(args[1], "_xDx.png"), res = 300, width = 8, height = 8, units = "in")

ggplot(xdx, aes(y = FULL_NAME, x = -log10(P))) +
    geom_bar(stat = "identity") +
    scale_y_discrete(labels = label_wrap(20)) +
    theme_classic() +
    xlab("") +
    ylab("")

dev.off()

png(paste0(args[1], "_Case_Case.png"), res = 300, width = 12, height = 15, units = "in")

ggplot(case_case, aes(y = FULL_NAME, x = -log10(P), fill = GWAS)) + 
    geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
    scale_y_discrete(labels = label_wrap(30)) + 
    theme_classic() + 
    facet_wrap(TRAIT ~ ., scales = "free", ncol = 2) + 
    scale_fill_manual(values = c("red", "blue")) +
    xlab("") + 
    ylab("")

dev.off()

png(paste0(args[1], "_Pairwise.png"), res = 300, width = 15, height = 20, units = "in")

ggplot(pairwise, aes(y = FULL_NAME, x = -log10(P))) + 
    geom_bar(stat = "identity") +
    scale_y_discrete(labels = label_wrap(30)) +
    theme_classic() + 
    xlab("") + 
    ylab("") + 
    facet_wrap(TRAIT ~ ., scales = "free", ncol = 3)

dev.off()