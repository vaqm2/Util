#!/usr/bin/env Rscript 

require(dplyr, quietly = TRUE)
require(ggplot2, quietly = TRUE)

args            = commandArgs(trailingOnly = TRUE)
assoc_files     = args[1]
snp_metrics     = args[2]
out             = args[3]
connection      = file(assc_files, "r")
assoc           = data.frame(matrix(ncol = 3))
colnames(assoc) = c("SNP", "P", "IMPUTE")

while(TRUE) {
    file_name = readLines(connection, 1)
    if(length(line) == 0) {
        break
    }
    else {
        line_contents = strsplit(line, "\t")
        file_name     = line_contents[0]
        file_label    = line_contents[1] 
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
}

assoc = inner_join(assoc, snp_metrics, by = c("SNP"))
assoc = assoc %>% 
    mutate(MAF = ifelse(AF > 0.5, 1 - AF, AF)) %>% 
    select(-AF) %>% 
    mutate(MAF_CATEGORY = cut(MAF, 
                              c(0.01, 0.05, 0.1, 0.5), 
                              labels = c("MAF_0.01", 
                                         "MAF_0.05",
                                         "MAF_0.1",
                                         "MAF_0.5"))) %>% 
    mutate(DR2_CATEGORY = cut(DR2,
                              c(0.3, 0.6, 0.8, 0.9, 1),
                              labels = c("DR2_0.3",
                                         "DR2_0.6",
                                         "DR2_0.8",
                                         "DR2_0.9",
                                         "DR2_1.0")))

png(paste0(out, "_", "QQ_by_MAF.png"), 
    res = 300, 
    units = "in", 
    height = 4, 
    width = 4)

ggplot(assoc, aes(sample = -log10(P), color = factor(MAF_CATEGORY))) +
    stat_qq() + 
    geom_abline(slope = 1) +
    scale_color_manual(values = c("red", "blue", "green", "brown")) +
    theme_bw()

dev.off()

png(paste0(out, "_", "QQ_by_DR2.png"), 
    res = 300, 
    units = "in", 
    height = 4, 
    width = 4)

ggplot(assoc, aes(sample = -log10(P), color = factor(DR2_CATEGORY))) +
    stat_qq() + 
    geom_abline(slope = 1) +
    scale_color_manual(values = c("red", "blue", "green", "brown", "cyan")) +
    theme_bw()

dev.off()