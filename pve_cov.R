#!/usr/bin/env Rscript

require(dplyr)

args  = commandArgs(trailingOnly = TRUE)
pheno = args[1]
covar = args[2]
phe_cov = inner_join(pheno, covar, by = c("fid", "iid"))
summary(lm(phe_cov$pheno ~ phe_cov$age))$adj.r.squared
summary(lm(phe_cov$pheno ~ phe_cov$sex))$adj.r.squared