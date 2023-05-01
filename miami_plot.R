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

p = ggmiami(data = results, 
            split_by = "study", 
            split_at = "Case vs Cohort",
            chr = "CHR",
            pos = "START",
            p = "P",
            upper_ylab = "Case vs Cohort",
            lower_ylab = "Case vs Other Cases",
            hits_label_col = c("GENE", "ZSTAT"),
            top_n_hits = 10,
            genome_line = 2.5e-6)

ggsave(p, 
       filename = paste0(args[3], ".png"), 
       device = "png", 
       width = 10, 
       height = 10, 
       units = "in", 
       res = 300)