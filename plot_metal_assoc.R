#!/usr/bin/env Rscript

require(dplyr, quietly = TRUE)
require(qqman, quietly = TRUE)
require(ggplot2, quietly = TRUE)
require(data.table, quietly = TRUE)

args = commandArgs(trailingOnly = TRUE)
assoc = fread(args[1], header = TRUE) 
out_prefix = args[2]

if("Is.SPA.converge" %in% colnames(assoc)) {
    assoc = assoc %>% filter(Is.SPA.converge == 1)
}

if("Is.converge" %in% colnames(assoc)) {
    assoc = assoc %>% filter(Is.converge == 1)
}
assoc = assoc %>% select(CHR, SNP, BP, P)
gws_snps = assoc %>% filter(P <= 5e-8)

png(paste(out_prefix, "Manhattan.png", sep = "_"),
    width = 10, 
    height = 5, 
    units = "in", 
    res = 300)

if(nrow(gws_snps) > 0) {
    manhattan(assoc, annotatePval = 5e-8)
} else {
    manhattan(assoc)
}

dev.off()

png(paste(out_prefix, "QQ.png", sep = "_"), 
    width = 5, 
    height = 5, 
    units = "in", 
    res = 300)
qq(assoc$P)
dev.off()