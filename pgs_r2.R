#!/usr/bin/env Rscript

require(dplyr, quietly = TRUE)
require(fmsb, quietly = TRUE)

args = commandArgs(trailingOnly = TRUE)
scores = read.table(args[1], header = T)
pheno_cov = read.table(args[2], header = T)

scores = scores %>% select("IID", "sBayesR_UKBB_2.8M") %>% rename(SCORE = sBayesR_UKBB_2.8M)
colnames(pheno_cov) = c("IID", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10", "Phenotype")
eval_df = inner_join(pheno_cov, scores, by = c("IID")) %>% unique()

null_model = glm(eval_df ~ . -IID -SCORE)
pgs_model = glm(eval_df ~ . -IID)
r2 = NagelkerkeR2(pgs_model)$R2 - NagelkerkeR2(null_model)$R2

print(paste0(args[1], "\t", args[2], "\t", r2))