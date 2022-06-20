#!/usr/bin/env Rscript

require(dplyr, quietly = TRUE)

args = commandArgs(trailingOnly = TRUE)

pheno = read.table(args[1], header = T)
fam_2012 = read.table(args[2], header = T)
fam_2015i = read.table(args[3], header = T)

colnames(fam_2012) = c("FID", "IID", "M", "F", "GENDER", "PHENO")
colnames(fam_2015i) = c("FID", "IID", "M", "F", "GENDER", "PHENO")

n_2012 = inner_join(fam_2012, pheno, by = c("IID")) %>% unique()
n_2015i = inner_join(fam_2015i, pheno, by = c("IID")) %>% unique()
cases_2012 = table(n_2012[ncols(n_2012)])[1]
cases_2015i = table(n_2015i[ncols(n_2015i)])[1]

print(paste0("iPSYCH2012 N: ", nrow(n_2012), " Cases : ", cases_2012))
print(paste0("iPSYCH2015i N: ", nrow(n_2015i), " Cases : ",cases_2015i))