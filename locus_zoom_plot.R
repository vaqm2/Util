#!/usr/bin/env Rscript

require(dplyr)
require(ggplot2)

args  = commandArgs(trailingOnly = TRUE)
assoc = read.table(args[1], header = TRUE)
assoc = assoc %>% mutate(GWSig = ifelse(P <= 5e-8, "YES", "NO"))
out   = paste0(args[2], "_", ".png")

png(out, width = 10, height= 8, units = "in", res = 300)

ggplot(assoc, aes(x = BP, y = -log10(P), shape = GWSig, color = GWSig)) + 
    geom_point() + 
    theme_bw() + 
    geom_hline(yintercept = -log10(1e-6), color = "blue", lty = 2) + 
    geom_hline(yintercept = -log10(5e-8), color = "red", lty = 2) +
    scale_color_manual(values = c("black", "red")) + 
    scale_shape_manual(values = c(1, 2))

dev.off()