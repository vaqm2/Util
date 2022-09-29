#!/usr/bin/env Rscript

require(qvalue, quietly = TRUE)
require(dplyr, quietly = TRUE)
require(data.table, quietly = TRUE)
require(ggplot2, quietly = TRUE)

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

sFDR_threshold_common = common_assoc %>% 
    arrange(Q) %>% 
    filter(Q <= 0.05) %>%
    select(P) %>%
    head(1)

sFDR_threshold_rare = rare_assoc %>% 
    arrange(Q) %>% 
    filter(Q <= 0.05) %>% 
    select(P) %>%
    head(1)

p = ggplot(logp, aes(x = Expected, y = Observed)) + 
    geom_point() +
    geom_abline(slope = 1) +
    theme_bw()

if(isTRUE(sFDR_threshold_common)) {
p = p + geom_vline(xintercept = sFDR_threshold_common, lty = 2, color = "blue") +
    annotate("text", 
             label = "sFDR Common SNPs = 0.05", 
             x = sFDR_threshold_common, 
             y = 0, 
             angle = 90,
             color = "blue")
}

if(isTRUE(sFDR_threshold_rare)) {
p = p + geom_vline(xintercept = sFDR_threshold_rare, lty = 2, color = "red") + 
    annotate("text", 
             label = "sFDR Common SNPs = 0.05", 
             x = sFDR_threshold_rare, 
             y = 0, 
             angle = 90,
             color = "red")
}

png(paste(args[2], "_QQ.png", sep = ""), 
    width = 8, 
    height = 8, 
    units = "in", 
    res = 300)

p

dev.off()

write.table(assoc, 
            paste(args[2], "_sFDR.txt", sep = ""), 
            row.names = F, 
            quote = F, 
            sep = " ")

# ---------------END OF SCRIPT ----------------- #