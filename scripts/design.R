#!/usr/bin/env Rscript

library(data.table)

metadata <- list.files(".", pattern="metadata", full.names = TRUE)

metadat <- read.csv(metadata, sep = ",")

condition_list <- sort(unique(metadat$condition))
for (cond1 in condition_list[seq(1,length(condition_list)-1)]) {
  cond1_index <- (match(cond1, condition_list))
  for (cond2 in condition_list[seq(cond1_index+1, length(condition_list))])
    write(paste0(cond1,"\t", cond2), file="design.txt", append = TRUE)
}