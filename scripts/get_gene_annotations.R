#' MAE gene annotations
#' Last update: 26-10-2026
#' Argument 1= input path .tsv
#' Argument 2= output path .tsv
#' Argument 3= gene annotation table (gene_annotation.tsv, made from the GTF)
#'
#' Genes come from the GTF used for counting (same table as for OUTRIDER and
#' FRASER): offline, and no TxDb / org.Hs.eg.db versions are involved.

suppressPackageStartupMessages({
    library(data.table)
    library(GenomicRanges)
})

args <- commandArgs(trailingOnly = TRUE)

res  <- read.table(args[1], header = TRUE, sep = "\t")
anno <- fread(args[3])

# chromosome names with or without "chr"; M and MT are the same contig
norm_chr <- function(x) {
    x <- sub("^chr", "", as.character(x))
    x[x == "M"] <- "MT"
    x
}

genes <- GRanges(norm_chr(anno$chr), IRanges(anno$start, anno$end))
gr    <- GRanges(norm_chr(res$chr), IRanges(res$start, res$end))

hits <- suppressWarnings(findOverlaps(gr, genes))

# A variant can overlap several genes: take the protein coding one, and of
# those the smallest (most specific) gene.
h <- data.table(q = queryHits(hits), s = subjectHits(hits))
h[, protein := anno$gene_type[s] == "protein_coding"]
h[, width := anno$end[s] - anno$start[s]]
setorder(h, q, -protein, width)
h <- h[!duplicated(q)]

idx <- rep(NA_integer_, nrow(res))
idx[h$q] <- h$s

message(sprintf("%.1f%% of the variants overlap an annotated gene",
                100 * mean(!is.na(idx))))
if (nrow(res) > 0 && all(is.na(idx))) {
    stop("No variant overlaps a gene of the annotation table. Do the ",
         "chromosome names of the MAE results and the GTF match?")
}

res$EnsemblID  <- anno$gene_id[idx]
res$hgncSymbol <- anno$gene_name[idx]
res$hgncSymbol[!is.na(res$hgncSymbol) & res$hgncSymbol == ""] <- NA

res <- as.data.frame(apply(res, 2, as.character))

write.table(res, args[2], sep = '\t', append = FALSE, row.names = FALSE, col.names = TRUE)


