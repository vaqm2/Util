#!/usr/bin/env Rscript 

require(dplyr, quietly = TRUE)
require(ggplot2, quietly = TRUE)

args                  = commandArgs(trailingOnly = TRUE)
assoc_files           = read.table(args[1], header = F)
colnames(assoc_files) = c("FILE", "CATEGORY")
snp_metrics           = read.table(args[2], header = T)
out                   = args[3]
assoc                 = data.frame(matrix(ncol = 3))
colnames(assoc)       = c("SNP", "P", "IMPUTE")

for (i in 1:nrow(assoc_files)) {
        file_name     = assoc_files[i, 1]
        file_label    = assoc_files[i, 2] 
        file_contents = read.table(file_name)
        colnames(file_contents) = c("CHROM",
                                    "POS",
                                    "SNP",
                                    "REF",
                                    "ALT",
                                    "A1",
                                    "TEST",
                                    "OBS_CT",
                                    "OR",
                                    "SE",
                                    "Z",
                                    "P")
        file_contents = file_contents %>% 
            filter(TEST == "ADD") %>% 
            select(SNP, P) %>% 
            mutate(IMPUTE = file_label)
        assoc = rbind(assoc, file_contents)
}

assoc = inner_join(assoc, snp_metrics, by = c("SNP"))
assoc = assoc %>% 
    mutate(MAF = ifelse(AF > 0.5, 1 - AF, AF)) %>% 
    select(-AF) %>% 
    mutate(MAF_CATEGORY = cut(MAF, 
                              c(0, 0.01, 0.05, 0.1, 0.5), 
                              labels = c("MAF < 0.01", 
                                         "0.01 <= MAF < 0.05",
                                         "0.05 <= MAF < 0.1",
                                         "0.1 <= MAF < 0.5"))) %>% 
    mutate(DR2_CATEGORY = cut(DR2,
                              c(0, 0.6, 0.8, 0.9, 1),
                              labels = c("0 <= DR2 < 0.6",
                                         "0.6 <= DR2 < 0.8",
                                         "0.8 <= DR2 < 0.9",
                                         "0.9 <= DR2 < 1.0")))

png(paste0(out, "_", "QQ.png"), 
    res = 300, 
    units = "in", 
    height = 12, 
    width = 12)

ggplot(assoc, aes(sample = -log10(P), color = IMPUTE)) +
    stat_qq() + 
    geom_abline(slope = 1, intercept = 0) +
    facet_grid(MAF_CATEGORY ~ DR2_CATEGORY, scales = "free") +
    scale_color_manual(values = c("red", "blue", "green", "brown")) +
    theme_bw() + 
    theme(legend.position = "bottom")

dev.off()