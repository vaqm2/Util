#!/usr/bin/env Rscript

require(qvalue)
require(dplyr)
require(data.table)

args = commandArgs(trailingOnly = TRUE)
assoc = fread(args[1], header = T)
assoc = assoc %>% 
    mutate(MAF = ifelse(FREQ > 0.5, 1 - FREQ, FREQ)) %>% 
    mutate(CLASS = ifelse(MAF >= 0.05, "COMMON", "RARE"))

rare_assoc = assoc %>% 
    filter(CLASS == "RARE") %>%
    mutate(Q = qvalue(p = P)$qvalues)

common_assoc = assoc %>% 
    filter(CLASS == "COMMON") %>%
    mutate(Q = qvalue(p = P)$qvalues)

assoc = rbind(common_assoc, rare_assoc) %>% arrange(CHR, BP)

logp_observed_common_df = -1 * log10(sort(common_assoc$P)) %>% as.data.frame()
logp_expected_common_df = -1 * log10(qunif(ppoints(nrow(logp_observed_common_df)))) %>% 
    as.data.frame()
logp_observed_rare_df   = -1 * log10(sort(rare_assoc$P)) %>% as.data.frame()
logp_expected_rare_df   = -1 * log10(qunif(ppoints(nrow(logp_observed_rare_df)))) %>% 
    as.data.frame()

colnames(logp_observed_common_df) = c("Observed")
colnames(logp_expected_common_df) = c("Expected")
colnames(logp_observed_rare_df)   = c("Observed")
colnames(logp_expected_rare_df)   = c("Expected")

logp_common = cbind(logp_observed_common_df, logp_expected_common_df)
logp_rare   = cbind(logp_observed_rare_df, logp_expected_rare_df)
logp = rbind(logp_common, logp_rare)
logp = logp %>% mutate(sFDR_0.05 = ifelse(Q <= 0.05, 1, 0))

png(paste(args[2], "_QQ.png", sep = ""), 
    width = 8, 
    height = 8, 
    units = "in", 
    res = 300)

ggplot(logp, aes(x = Expected, y = Observed, shape = sFDR_0.05, color = sFDR_0.05)) + 
    geom_point() +
    geom_abline(slope = 1) +
    theme_bw() + 
    scale_color_manual(values = c("blue", "red"))

dev.off()

write.table(assoc, 
            paste(args[2], "_sFDR.txt", sep = ""), 
            row.names = F, 
            quote = F, 
            sep = " ")

# ---------------END OF SCRIPT ----------------- #