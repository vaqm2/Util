#!/usr/bin/env Rscript

require(bigsnpr, quietly = TRUE)

args = commandArgs(trailingOnly = TRUE)

snp_readBed(args[1])