#'---
#' MAE process adopted from:
#' title: Get MAE results
#' author: vyepez, mumichae
#' arguments:
#' [1] = MAE count file
#' [2] = output path
#'---

suppressPackageStartupMessages({
    library(stringr)
    library(tMAE)
})

message("Started with deseq")

args <- commandArgs(trailingOnly = TRUE)

# Read mae counts
mae_counts <- fread(args[1], fill=TRUE)
mae_counts <- mae_counts[contig != '']
mae_counts[, position := as.numeric(position)]

# Sort by chr
mae_counts <- mae_counts[!grep("Default|opcode", contig)]
mae_counts[,contig := factor(contig, 
                levels = unique(str_sort(mae_counts$contig, numeric = TRUE)))]


print("Running DESeq...")
# Function from tMAE pkg
res <- DESeq4MAE(mae_counts) ## negative binomial test for allelic counts

# add start-end to the df, change names for compatibility
# for later one base (for .bed), subtracted 1 from the variant position.
res$start <- res$position - 1

names(res)[names(res) == 'position'] <- 'end'
names(res)[names(res) == 'contig'] <- 'chr'
names(res)[names(res) == 'padj'] <- 'padjust'

res$sampleID <- args[3] #add sampleid for dashboard or concatenating later. 

write.table(res, args[2], sep='\t', append = FALSE, row.names = FALSE, col.names = TRUE)