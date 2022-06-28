#!/usr/bin/env Rscript

require(dplyr, quietly = TRUE)
require(fmsb, quietly = TRUE)

liability_transform = function(r2, k, p) {
    if(r2 == 0) {
        return (r2)
    } else {
        x     = qnorm(1 - k)
        z     = dnorm(x)
        i     = z / k
        cc    = k * (1 - k) * k * (1 - k) / (z * z * p * (1 - p))
        theta = i * ((p - k) / (1 - k)) * (i * ((p - k) / (1- k)) - x)
        e     = 1 - p^(2 * p) * (1 - p)^(2 * (1 - p))
        r2_L  = cc * e * r2 / (1 + cc * e * theta * r2)
        return (r2_L)
    }
}

k         = 0
p         = 0
args      = commandArgs(trailingOnly = TRUE)
scores1   = read.table(args[1], header = T)
scores2   = read.table(args[2], header = T)
pheno_cov = read.table(args[3], header = T)
p         = as.numeric(args[4])

scores1 = scores1 %>% select("IID", "sBayesR_UKBB_2.8M") %>% 
    rename(SCORE1 = sBayesR_UKBB_2.8M)
scores2 = scores2 %>% select("IID", "sBayesR_UKBB_2.8M") %>% 
    rename(SCORE2 = sBayesR_UKBB_2.8M)
colnames(pheno_cov) = c("IID", "Age", "gender", "PC1", "PC2", "PC3", "PC4", 
                        "PC5", "PC6", "PC7", "PC8", "PC9", "PC10", "Phenotype")
eval_df = inner_join(pheno_cov, scores1, by = c("IID")) %>% unique()
eval_df = inner_join(eval_df, scores2, by = c("IID")) %>% unique()

k = sum(eval_df$Phenotype)/nrow(eval_df)

null_model = glm(data = eval_df, Phenotype ~ . -IID -SCORE1 - SCORE2)
pgs_model = glm(data = eval_df, Phenotype ~ . -IID)
r2 = NagelkerkeR2(pgs_model)$R2 - NagelkerkeR2(null_model)$R2
p_val = pchisq(deviance(null_model) - deviance(pgs_model), 
               df.residual(null_model) - df.residual(pgs_model), 
               lower.tail = F)

if(p > 0) {
    r2_L = liability_transform(r2, k, p)
}

print(paste0("R2: ", r2, " ", "R2_L: ", r2_L, " ", "P: ", p_val))