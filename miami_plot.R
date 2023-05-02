#!/usr/bin/env Rscript

library(dplyr, quietly = TRUE)
library(miamiplot, quietly = TRUE)
library(data.table, quietly = TRUE)
library(ggplot2, quietly = TRUE)

args    = commandArgs(trailingOnly = TRUE)
study1  = fread(args[1], header = T)
study1  = study1 %>% mutate(study = "Case vs Cohort")
study2  = fread(args[2], header = T)
study2  = study2 %>% mutate(study = "Case vs Other Cases")
results = rbind(study1, study2)

png(filename = paste0(args[3], ".png"), 
    width    = 10, 
    height   = 10, 
    units    = "in", 
    res      = 300)

ggmiami(data                  = results, 
        split_by              = "study", 
        split_at              = "Case vs Cohort",
        chr                   = "CHR",
        pos                   = "START",
        p                     = "P",
        upper_ylab            = "Case vs Cohort",
        lower_ylab            = "Case vs Other Cases",
        hits_label_col        = c("GENE", "PHENOTYPE"),
        top_n_hits            = NULL,
        genome_line           = 2.5e-6,
        suggestive_line       = NULL,
        upper_highlight_color = "green",
        lower_highlight_color = "green")

dev.off()