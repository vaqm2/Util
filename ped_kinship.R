#!/usr/bin/env Rscript

library(kinship2)
library(dplyr)
data(minnbreast)

breast_ped  = pedigree(id = minnbreast$id, 
                       dadid = minnbreast$fatherid, 
                       momid = minnbreast$motherid, 
                       sex = minnbreast$sex,
                       famid = minnbreast$famid)
breast_kin = kinship(breast_ped)
breast_kin_triplet = as(as(breast_kin, "generalMatrix"), "TsparseMatrix")
breast_kin_df = data.frame(ID1 = rownames(breast_kin_triplet)[breast_kin_triplet@i + 1],
                           ID2 = colnames(breast_kin_triplet)[breast_kin_triplet@j + 1],
                           Kinship_Coef = breast_kin_triplet@x)
breast_kin_df = breast_kin_df %>% filter(Kinship_Coef > 0)
write.table(breast_kin_df, 
            "MinnBreastKinship2.out", 
            sep = "\t", 
            row.names = F,
            quote = F)