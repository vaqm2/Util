#!/usr/bin/env Rscript

require(qvalue)
require(dplyr)
require(data.table)

args = commandArgs(trailingOnly = TRUE)
assoc = fread(args[1], header = T)
assoc = assoc %>% 
    mutate(MAF = ifelse(FREQ > 0.5, 1 - FREQ, FREQ)) %>% 
    mutate(CLASS = ifelse(FREQ >= 0.05, "COMMON", "RARE"))

rare_assoc = assoc %>% 
    filter(CLASS == "RARE") %>%
    mutate(Q = qvalue(p = P)$qvalues)

common_assoc = assoc %>% 
    filter(CLASS == "COMMON") %>%
    mutate(Q = qvalue(p = P)$qvalues)

assoc = rbind(common_assoc, rare_assoc) %>% arrange(CHR, BP)

write.table(assoc, args[2], row.names = F, quote = F, sep = " ")

# ---------------END OF SCRIPT ----------------- #