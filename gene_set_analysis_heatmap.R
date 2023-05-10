#!/usr/bin/env Rscript

library(dplyr)
library(ggplot2)
library(stringr)

setwd("/Users/vapp0002/Desktop/Magma/")

enrichment          = read.table("PsychEncodeModulesEnrichments.txt", header = T)
enrichment          = enrichment %>% mutate(TYPE = str_count(GWAS, "_"))
enrichment$TYPE     = gsub("2", "Case vs Case Pairwise", enrichment$TYPE)
enrichment$TYPE     = gsub("1", "Case vs Other Cases", enrichment$TYPE)
enrichment$TYPE     = gsub("0", "Case vs Cohort", enrichment$TYPE)
enrichment$GWAS     = gsub("_CC", "", enrichment$GWAS)
enrichment$GWAS     = gsub("_", " vs ", enrichment$GWAS)
enrichment$VARIABLE = gsub("^ME", "", enrichment$VARIABLE)
enrichment$VARIABLE = as.numeric(enrichment$VARIABLE)



png("PsychEncodeModules_Enrichments.png",
    res = 300,
    width = 12,
    height = 8,
    units = "in")

ggplot(enrichment, aes(x = VARIABLE, y = GWAS, fill = BETA, size = -log10(P))) +
    geom_point(shape = 21) +
    theme_classic() +
    scale_fill_gradient2(low = "blue", mid = "white", high = "red") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
          axis.text.y = element_text(face = "bold"),
          legend.position = "bottom") +
    xlab("") +
    ylab("") +
    facet_grid(TYPE ~ ., scales = "free", space = "free") +
    scale_x_continuous(breaks = seq(1, 73, 1))

dev.off()