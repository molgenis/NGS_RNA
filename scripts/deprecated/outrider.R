#!/usr/bin/env Rscript

argv <- commandArgs(TRUE)
outputdir <- argv[1]
#plot_gene <- argv[2]

#print(plot_gene)
#genes <- read.delim(plot_gene, header = FALSE)
#print(genes)

# Load workspace
#library(OUTRIDER)
load(paste(outputdir,'outrider.ods.Rds',sep=''))

head(ods) 

#res <- results(ods, all=TRUE)
#ressign <- results(ods, padjCutoff=0.05)

## P-values versus Mean Count
pdf(paste(outputdir,'QC/', 'plotPowerAnalysis.pdf', sep = ""))
print(plotPowerAnalysis(ods))
dev.off()

# PLOT Volcano plots
cat("Ploting volcano plot per sample.\n")

head(ods)

for (sample in ods$sampleID){
	filename <- paste0(outputdir, sample,'/QC/', sample ,'.plotVolcano.pdf')
	pdf(filename)
	print(plotVolcano(ods,sample, basePlot=TRUE))
  	dev.off()

	plot_gene <- paste0(outputdir, sample,'/',sample,'.genesOfInterest.tsv')
	# readin genelist if exists and not empty
	if (file.exists(plot_gene)&(file.size(plot_gene) > 0)){
		genes <- read.delim(plot_gene, header = FALSE)
		print(genes)
	} else {
		print("Gene list is empty!")
		stop("exit")
	}

	cat("Plotting gene level plot\n")
	for (gene in genes$V1){
		pdf(paste0(outputdir,sample,"/QC/",gene,".plotExpressionRank.pdf", sep = ""))
		print(plotExpressionRank(ods, gene , basePlot=TRUE))
		dev.off()

		cat("Plotting QQ plot\n")
		pdf(paste0(outputdir,sample,"/QC/",gene,".plotQQ.pdf", sep = ""))
 		print(plotQQ(ods, gene))
		dev.off()

		cat("Plotting plotExpectedVsObservedCounts  plot\n")
		pdf(paste0(outputdir,sample,"/QC/",gene,".plotExpectedVsObservedCounts.pdf", sep = ""))
		print(plotExpectedVsObservedCounts(ods, gene, basePlot=TRUE))
		dev.off()
	} 
}
