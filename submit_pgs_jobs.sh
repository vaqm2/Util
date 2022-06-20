#!/usr/bin/env perl

trait=

sbatch --mem=8g --time=48:00:00 \
--account=cross_disorder_2 \
--error=ADHD_ANO_CC_2012.err \
--output=ADHD_ANO_CC_2012.out \
--job-name=ADHD_ANO_2012_CC \
--chdir=/faststorage/jail/project/cross_disorder_2/people/vivapp/PGS/iPSYCH2012_ADHD_ANO_SAIGE_CC/ \
--wrap="nextflow run /faststorage/jail/project/proto_psych_pgs/scripts/ibp_pgs_pipelines/main.nf \
--ref /faststorage/jail/project/cross_disorder_2/people/vivapp/PGS/iPSYCH2012_ADHD_ANO_SAIGE_CC/iPSYCH2012_ADHD_ANO_SAIGE_CC.vcf.gz \
--target /faststorage/jail/project/proto_psych_pgs/scripts/ibp_pgs_pipelines/JSON/iPSYCH2012_All_Imputed_2021_QCed.json \
--trait ADHD_ANO_CC \
--pheno /faststorage/jail/project/cross_disorder_2/people/vivapp/PGS/phenotype.txt \
"