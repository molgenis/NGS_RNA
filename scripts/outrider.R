#!/usr/bin/env Rscript

# GAD PIPELINE #
# run_outrider.R
# Description : This script allows user to run OUTRIDER command for DE analysis
# Usage : Rscript run_de_analysis.R <count_matrix> <design_file> <output_directory>
# Output : tabulated output file with DE results and QC plots
# Requirements : Rscript, OUTRIDER

# Author : Emilie.Tisserant u-bourgogne fr , yannis.duffourd u-bourgogne fr
# Creation Date : 20180920
# last revision date : 20201021
# Known bugs : None


argv <- commandArgs(TRUE)
inputfile <- argv[1]
metafile <- argv[2]
outputdir <- argv[3]
gtf <- argv[4]
plot_sample <- argv[5]
plot_gene <- argv[6]



# Logging
#sink(file=paste(outputdir, basename, ".log.txt", sep = ""))

# Load package
library(OUTRIDER)

# Read data
cat("Loading data")
ctsTable <- read.table(inputfile, sep="\t" , as.is = T , header=T , row.names = 1)
metadata <- read.delim(metafile, sep="\t" , as.is = T , header=T)

head(ctsTable)
print(metadata)

# Create ods object
ods <- OutriderDataSet(countData=ctsTable)
dim(ods)


# TODO annotfile, other method, cutoff
# calculate FPKM values and label not expressed genes
cat( "Computing FPKM values")
ods <- filterExpression(ods, gtf ,filterGenes=FALSE, savefpkm=TRUE)

head(ods)

#mcols(ods)$basepairs <- 1
#mcols(ods)$passedFilter <- rowMeans(counts(ods)) > 10



# PLOT display the FPKM distribution of counts
cat ("Ploting FPKM distribution")
pdf(paste(outputdir, "/QC/plotFPKM.pdf", sep = ""))
plotFPKM(ods)
dev.off()

# do the actual subsetting based on the filtering labels
ods <- ods[mcols(ods)$passedFilter,]
dim(ods)
# TODO log dim(ods)



# TODO q cutoff
#ods <- findEncodingDim(ods)
#pdf(paste(outputdir, "/QC/EncDim.pdf",  sep = ""))
#plotEncDimSearch(ods)
#dev.off()
cat("Estimating Q")
estimateBestQ(ods)

# automatically control for confounders, encoding dimension estimation
ods <- estimateSizeFactors(ods)
# ods <- autoCorrect(ods, q=qvalue)
# ods <- controlForConfounders(ods, q=13)
ods <- controlForConfounders(ods)

# TODO log result

# TODO nCluster cutoff, metadata
# PLOT Heatmap of the sample correlation before and after controlling
cat( "Ploting heatmap of the sample correlation : " , paste(outputdir, "/QC/plotCorr.pdf",  sep = "") , "\n")
colData(ods)$type <- metadata$type
pdf(paste(outputdir, "/QC/plotCorr.pdf",  sep = ""))
ods <- plotCountCorHeatmap(ods, normalized=FALSE, colCoFactor="type")
# ods <- plotCountCorHeatmap(ods, colGroups="type")
dev.off()

cat( "Ploting heatmap of the sample correlation before : " , paste(outputdir, "/QC/plotCorrBefore.pdf",  sep = "") , "\n")
pdf(paste(outputdir, "/QC/plotCorrBefore.pdf",  sep = ""))
ods <- plotCountCorHeatmap(ods, normalized=FALSE, colCoFactor="type")
dev.off()

cat( "Ploting heatmap of the sample correlation after : " , paste(outputdir, "/QC/plotCorrAfter.pdf",  sep = "") , "\n")
pdf(paste(outputdir, "/QC/plotCorrAfter.pdf",  sep = ""))
ods <- plotCountCorHeatmap(ods, colCoFactor="type")
dev.off()

# fit negative binomial distribution to each feature
cat("Fitting binomial distribution\n")

#PEER PCA ???
#ods <- peer(ods)

ods <- fit(ods)

# PLOT dispersion versus mean counts
cat("Ploting dispersion\n")
pdf(paste(outputdir, "/QC/DispEsts.pdf", sep = ""))
plotDispEsts(ods)
dev.off()

# compute P-values (nominal and adjusted) "fdr"
cat( "Computing p-values\n")
ods <- computePvalues(ods, alternative="two.sided", method="BY")


# compute the Z-scores
cat("Computing Zscores\n")
ods <- computeZscores(ods)

# TODO cutoff
# Print Result
cat("Writing results\n")
res <- results(ods, all=TRUE)
ressign <- results(ods, padjCutoff=0.05)
write.table(res, file=paste(outputdir, "/outrider.tsv", sep = ""), sep = "\t" , row.names = TRUE, col.names = NA)
write.table(ressign, file=paste(outputdir, "/outrider.sign.tsv", sep = ""), sep = "\t" , row.names = TRUE, col.names = NA)

# TODO cutoff
# PLOT plot the aberrant events per sample
cat("Ploting aberrant events\n")
pdf(paste(outputdir, "/QC/plotAberrantPerSample.pdf", sep = ""))
plotAberrantPerSample(ods, padjCutoff=0.05)
dev.off()

save.image(outputdir, file='outrider.session.RData')

# TODO plot for significant samples/genes, loop

# PLOT Volcano plots
cat("Ploting volcano plot for sample:", plot_sample," \n")

head(ods)

pdf(paste(outputdir, "/QC/plotVolcano.pdf", sep = ""))
plotVolcano(ods, plot_sample , basePlot=TRUE)
dev.off()


# PLOT Gene level plots
cat("Ploting gene level plot\n")
#pdf(paste(outputdir, "/QC/plotExpressionRank.pdf", sep = ""))
#plotExpressionRank(ods, plot_gene , basePlot=TRUE)
#dev.off()


## PLOT QQ-plot for a given gene
cat("Ploting QQ plot\n")
#pdf(paste(outputdir, "/QC/plotQQ.pdf", sep = ""))
#plotQQ(ods, plot_gene)
#dev.off()

cat("Ploting QQ plot\n")
## Observed versus expected gene expression
#plotExpectedVsObservedCounts(ods, plot_gene, basePlot=TRUE)
#dev.off()

## P-values versus Mean Count
plotPowerAnalysis(ods)
dev.off()

# Write RDS
cat("Wrting RDS results")
saveRDS(ods, file = paste(outputdir, "/ods.RDS", sep = ""))
saveRDS(res, file = paste(outputdir, "/res.RDS", sep = ""))

#normalizationFactor
#sampleExclusionMask(ods) <- FALSE
#sampleExclusionMask(ods[,"MUC1365"]) <- TRUE
