#!/usr/bin/env Rscript

# Loading libraries and setting the requisite directory in which the count.txt files are stored.
# Next the list of files is set as sampleFiles.

library("DESeq2", "apeglm")
suppressPackageStartupMessages( library("DESeq2", "apeglm"))
library("data.table", "ggplot2")
suppressPackageStartupMessages( library("data.table", "ggplot2"))
library(ggrepel)

# Annotation file is loaded as data table and sorted, with setkey, on gene id. Metadata is read and useful
# corrections are made in the metadat data frame. This ensures that the sample files can be paired to the
# information in the metadat data frame.

#get samplesheet args[1], and annotation file. args[2]
args = commandArgs(trailingOnly=TRUE)

print(args[1])
print(args[2])



counts = list.files(".", pattern=".counts.txt", full.names=TRUE)
sampleID <- args[2]

#annotation = list.files(".", pattern="_nodupes_genid.bak", full.names = TRUE)
metadata <- args[1]
#metadata = list.files(".", pattern="metadata", full.names = TRUE)
design = list.files(".", pattern = "design.txt", full.names = TRUE)

sampleFiles <- counts
print(sampleFiles)

#ref_annot <- as.data.table(read.table(annotation, header = TRUE))
#setkey(ref_annot, Gene_id)

metadat <- read.csv(metadata, sep = ",")
print(metadat)

sampleTable <- data.frame(sampleName = sort(metadat$externalSampleID), fileName = sort(sampleFiles), condition = metadat[order(metadat$externalSampleID), , drop=FALSE]$condition)
print(sampleTable)

ddsHTSeq <- DESeqDataSetFromHTSeqCount(sampleTable = sampleTable, directory = ".", design = ~ condition)
print(ddsHTSeq) 

# From the ddsHTSeq DESeqDataSet only the rows with a sum of 10 or higher are selected and used to continue
# analysis with. By removing rows in which there are very few reads, the memory size of the dds data object is
# reduced, and the  speed of the transformation and testing functions within DESeq2 is increased.

keep <- rowSums(counts(ddsHTSeq)) >=10
ddsHTSeq <- ddsHTSeq[keep,]
print(ddsHTSeq)

# The sampleTable is built using sample-ids from the metadat data frame, filenames from the sampleFiles list, and
# the conditions listed in the metadat data frame. After this the DESeqDataSet is built using the sampleTable, the
# path to the count.txt files, and a design is loaded based on the conditions.

design <-read.table(design, sep = "\t")
# For each condition the reference group (condition) is set and differential expression analysis is performed with
# DESeq. The coefficient names are checked with resultNames and the different coefficients are then used to perform
# log fold shrinkage. Shrinkage of effect size (LFC estimates) is useful for visualization and ranking of genes, the
# apeglm method for effect size shrinkage (Zhu, Ibrahim, and Love 2018) and improves on the previous estimator.
# The gene names for the corresponding ensemble gene-ids are added to the lfcShrink DESeqResults.
# The results, in DESeqResults format, are ordered on smallest adjusted p value and a summary of the results is
# shown with summary, with alpha is 0.05. An overview of the top significant, up and down regulated, genes are
# shown. The results are saved to a csv file.
# PCA plots are constructed using the logarithm transformed data. This is done for each comparison.

for (row in 1:nrow(design)){
  cond1 <- as.character(design[row, "V1"])
  cond2 <- as.character(design[row, "V2"])
  print(paste0(cond1, ", ",cond2))
  
  
  ddsHTSeq$condition <- relevel(ddsHTSeq$condition, ref = cond1)
  dds <- DESeq(ddsHTSeq, quiet=T)
  print(resultsNames(dds))
 
  resLFC <- lfcShrink(dds, coef=paste0("condition_", cond2,"_vs_",cond1), type="apeglm") ##
  res <- results(dds, name=paste0("condition_", cond2,"_vs_",cond1))
  res$geneName <- rownames(res)
#  res$geneName <- ref_annot[rownames(res)]$Gene_name
  resOrdered <- res[order(res$padj),]
  head(subset(resOrdered, log2FoldChange >= 0 & padj <= 0.05))
  head(subset(resOrdered, log2FoldChange <= 0 & padj <= 0.05))
  
  write.csv(subset(resOrdered, log2FoldChange >= 0 & padj <= 0.05), file = paste0(sampleID,"_deseq2_up_", cond1, "_vs_", cond2, ".csv"))
  write.csv(subset(resOrdered, log2FoldChange <= 0 & padj <= 0.05), file = paste0(sampleID,"_deseq2_down_", cond1, "_vs_", cond2, ".csv"))
  write.csv(resOrdered, file = paste0(sampleID,"_deseq2_", cond1, "_vs_" , cond2, ".csv"))
  
  ntd <- normTransform(dds)
  plotdds <- ntd[ , ntd$condition %in% c(cond1, cond2)]
  plota <- ntd
  
  svg(paste0(sampleID,"_pca_deseq2_labels_", cond1, "_vs_", cond2, ".svg"))
  pca <- plotPCA(plotdds, intgroup=c("condition"))
  nudge <- ggplot2::position_nudge(y = 1.5)
  print(pca + ggplot2::geom_text(ggplot2::aes(label = name), position = nudge))
  dev.off()
  
  svg(paste0("pca_deseq2_labels_all.svg"))
  pca <- plotPCA(plota, intgroup=c("condition"), returnData = TRUE)
  percentVar <- round(100 * attr(pca, "percentVar"))
  p <- ggplot2::ggplot(pca, ggplot2::aes(x=PC1, y=PC2, color=condition))
  p <- p + ggplot2::geom_point(size=3) + ggplot2::xlab(paste0("PC1: ",percentVar[1],"% variance")) +
    ggplot2::ylab(paste0("PC2: ",percentVar[2],"% variance"))
  nudge <- ggplot2::position_nudge(y = 1.5)
  print(p + ggplot2::geom_text(ggplot2::aes(label = name), position = nudge))
  dev.off()
  
  svg(paste0(sampleID,"_volcano_plot_", cond1, "_vs_", cond2, ".svg"))
  resOrdered$Significant <- ifelse(resOrdered$padj <0.05, "padj < 0.05", ifelse(abs(resOrdered$log2FoldChange) > 1, "LFC > 1", "None"))
  resOrdered <- as.data.frame(resOrdered)
  p <- ggplot(resOrdered, aes(x = log2FoldChange, y = -log10(pvalue))) +
    geom_point(aes(color = Significant), size=2) +
    scale_color_manual(values = c("#CC6666", "#000000", "#FF0000")) +
    theme_bw(base_size = 12) + theme(legend.position = "none") +
    geom_text_repel(
      data = subset(resOrdered, abs(log2FoldChange) > 1 | padj < 0.05)[1:20,],
      aes(label = geneName),
      size = 4,
      box.padding = unit(0.35, "lines"),
      point.padding = unit(0.3, "lines")
    ) +
    geom_vline(xintercept = c(-1, 1),col="#333333",lty=2) +
    geom_hline(yintercept = c(-log10(0.05)), col="#CC3333", lty=2)
  print(p)
  dev.off()
}
