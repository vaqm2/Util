#!/usr/bin/env Rscript

require(dplyr)

args = commandArgs(trailingOnly = TRUE)
pheno = read.table(args[1], header = T)
fam_2012 = read.table(args[2], header = T)
colnames(fam_2012) = c("FID", "IID", "M", "F", "GENDER", "PHENO")
fam_2015i = read.table(args[3], header = T)
colnames(fam_2015i) = c("FID", "IID", "M", "F", "GENDER", "PHENO")
n_2012 = semi_join(fam_2012, pheno, by = c("IID")) %>% nrow()
n_2015i = semi_join(fam_2015i, pheno, by = c("IID")) %>% nrow()
n_cases_2012 = semi_join(fam_2012, pheno, by = c("IID")) %>% filter(PHENOTYPE == 1) %>% nrow()
n_cases_2015i = semi_join(fam_2015i, pheno, by = c("IID")) %>% filter(PHENOTYPE == 1) %>% nrow()

print(paste0("iPSYCH2012 N: ", n_2012, "Cases : ", n_cases_2012))
print(paste0("iPSYCH2015i N: ", n_2015i, "Cases : ", n_cases_2015i))