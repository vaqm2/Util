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

common_assoc = common_assoc %>% 
    mutate(Observed = -1 * log10(P)) %>% 
    arrange(desc(Observed))

rare_assoc = rare_assoc %>% 
    mutate(Observed = -1 * log10(P)) %>% 
    arrange(desc(Observed))

logp_expected_common_df = -1 * log10(qunif(ppoints(nrow(common_assoc)))) %>% 
    as.data.frame()
logp_expected_rare_df   = -1 * log10(qunif(ppoints(nrow(rare_assoc)))) %>% 
    as.data.frame()
colnames(logp_expected_common_df) = c("Expected")
colnames(logp_expected_rare_df)   = c("Expected")

common_assoc = cbind(common_assoc, logp_expected_common_df)
rare_assoc   = cbind(rare_assoc, logp_expected_rare_df)
assoc        = rbind(common_assoc, rare_assoc)

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

p = ggplot(assoc, aes(x = Expected, y = Observed, color = CLASS, shape = CLASS)) + 
    geom_point() +
    geom_abline(slope = 1) +
    theme_bw() + 
    scale_color_manual(values = c("blue", "red"))

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