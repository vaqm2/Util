#!/usr/bin/env Rscript

require(dplyr)

args      = commandArgs(trailingOnly = TRUE)
pheno     = read.table(args[1], header = T)
covar     = read.table(args[2], header = T)
phe_cov   = inner_join(pheno, covar, by = c("fid", "iid"))
full_r2   = summary(lm(data = phe_cov, pheno ~ . -fid -iid))$adj.r.squared
wo_age_r2 = summary(lm(data = phe_cov, pheno ~ . -fid -iid -age))$adj.r.squared
wo_sex_r2 = summary(lm(data = phe_cov, pheno ~ . -fid -iid -sex))$adj.r.squared
age_r2    = full_r2 - wo_age_r2
sex_r2    = full_r2 - wo_sex_r2

cat("Proportion of Variance Explained by all Covariates : ")
cat(full_r2)
cat("\n")
cat("Proportion of Variance Explained by age : ")
cat(age_r2)
cat("\n")
cat("Proportion of Variance Explained by sex : ")
cat(sex_r2)
cat("\n")