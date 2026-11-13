import sys
import json
import argparse
import pandas as pd
import plotly.express as px
import numpy as np
from jinja2 import Template
from gprofiler import GProfiler


#Plot functions

def scatter_plot_mae(data, padj_treshold=0.05):
    """
    Scatter plot function for outrider (gene expression) data.
    --------------
    inputs:
        data = pd.DataFrame

    outputs:
        fig_html = interactive plotly html code (HTML)    

    """
    data = data.replace([np.inf, -np.inf], 1)
    data = data.replace(np.nan, 1)
    data["minlogpVal"] = -np.log(data.pValue)
    data["significant"] = ['True' if padj < padj_treshold else "False" for padj in data["padjust"]]
    fig = px.scatter(data, x="log2FC", y="minlogpVal", hover_data=["gene"], color_discrete_map={"True":"rgba(255, 30, 30, 0.8)","False":"rgba(60, 60, 60, 0.8)"}, color='significant', labels={
                    "log2FC": "log2FC",
                    "minlogpVal": "-log pValue",
                }, title="MAE volcano plot")
    fig.update_layout(
                        plot_bgcolor='rgba(0, 0, 0, 0)',
                        paper_bgcolor='rgba(0, 0, 0, 0)',
                        width=500,
                        title_x=0.5
                    ),
    fig_html = fig.to_html(full_html=False)
    return fig_html


def _normalize_chr_series(chr_series: pd.Series) -> pd.Series:
    """
    Normalize chromosome notation to comparable format:
      - remove 'chr' prefix if present
      - uppercase
      - map M -> MT
    """
    s = chr_series.astype(str).str.strip().str.upper()
    s = s.str.replace("^CHR", "", regex=True)
    s = s.replace({"M": "MT"})
    return s

def load_gene_panel(gene_panel_file: str):
    """
    Loads a gene panel, detecting whether it is txt or bed.
    Returns:
      - set of gene symbols   if .txt
      - DataFrame of intervals if .bed
    """
    if gene_panel_file.endswith(".txt"):
        with open(gene_panel_file) as f:
            genes = {line.strip() for line in f if line.strip()}
        return genes

    elif gene_panel_file.endswith(".bed"):
        # Read at least chr, start, end; ignore extra columns if present
        bed = pd.read_csv(
            gene_panel_file,
            sep="\t",
            header=None,
            comment="#",
            usecols=[0, 1, 2],
            names=["chr", "start", "end"],
        ).copy()

        # Normalize chr and enforce ints
        bed["chr"]   = _normalize_chr_series(bed["chr"])
        bed["start"] = bed["start"].astype(np.int64)
        bed["end"]   = bed["end"].astype(np.int64)

        # Sanity: drop intervals with start >= end
        bed = bed[bed["start"] < bed["end"]].reset_index(drop=True)
        return bed

    else:
        raise ValueError("File must end in .txt or .bed")


def filter_by_gene_panel(df: pd.DataFrame, gene_panel_file: str) -> pd.DataFrame:
    """
    Filters df either by geneSymbol (.txt panel)
    or by genomic overlaps (.bed panel).

    Assumptions:
      - df has columns: 'chr', 'start', 'end' (1-based inclusive)
      - .bed is standard UCSC BED (0-based, half-open)
    """
    gp = load_gene_panel(gene_panel_file)

    # Gene-list filtering
    if isinstance(gp, set):
        if "geneSymbol" not in df.columns and "gene" in df.columns:
            # Allow 'gene' as an alias commonly used in your dataframes
            return df[df["gene"].isin(gp)].copy()
        return df[df["geneSymbol"].isin(gp)].copy()

    # BED-based filtering
    bed_df = gp

    # Ensure required columns present
    for col in ["chr", "start", "end"]:
        if col not in df.columns:
            raise ValueError(f"Input dataframe is missing required column '{col}' for BED filtering.")

    # Work on a copy; drop rows without coordinates
    work = df.dropna(subset=["chr", "start", "end"]).copy()

    # Normalize chromosome names to same scheme as BED
    work["chr_norm"] = _normalize_chr_series(work["chr"])

    # Coerce to integer (1-based inclusive)
    work["start"] = work["start"].astype(np.int64)
    work["end"]   = work["end"].astype(np.int64)

    # Convert to 0-based half-open to compare with BED properly
    # 1-based inclusive [start, end]  -->  0-based half-open [start-1, end)
    work["_start0"] = work["start"] - 1
    work["_end0"]   = work["end"]

    # Build mask per chromosome using half-open overlap:
    # overlap if df_start0 < bed_end  AND  df_end0 > bed_start
    mask_all = np.zeros(len(work), dtype=bool)

    # Process per chromosome to reduce comparisons
    for chrom, bed_chr in bed_df.groupby("chr", sort=False):
        sel = (work["chr_norm"] == chrom)
        if not sel.any():
            continue
        wchr = work.loc[sel, ["_start0", "_end0"]].to_numpy()
        if wchr.size == 0:
            continue

        starts0 = wchr[:, 0]
        ends0   = wchr[:, 1]

        # Accumulate overlaps for this chrom
        mask_chr = np.zeros(starts0.shape[0], dtype=bool)
        for _, r in bed_chr.iterrows():
            # Strict half-open logic
            mask_chr |= (starts0 < int(r["end"])) & (ends0 > int(r["start"]))

        # Write back into the global mask
        mask_all[sel.to_numpy()] |= mask_chr

    filtered = work.loc[mask_all].copy()

    # Remove helper columns and de-duplicate
    filtered = filtered.drop(columns=["chr_norm", "_start0", "_end0"], errors="ignore").drop_duplicates()

    # Return empty DataFrame with original columns if nothing matched
    if filtered.empty:
        return df.iloc[0:0].copy()

    print(filtered)

    return filtered


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='RNA outlier HTML report module')
    parser.add_argument('-ma','--mae', help='MAE results .tsv; example: path/to/mae_results_patient_x.tsv', required=True)
    parser.add_argument('-t','--template', help='Html template; example: path/to/template.html', required=True)
    parser.add_argument('-s','--sampleid', help='Sample id used in reporting', required=True)
    parser.add_argument('-o','--output', help='Output path; example: path/to/patient_x_report.html', required=True)
    parser.add_argument('-g','--genepanel', help='Gene panel .txt file, one gene per line; example: path/to/genes.txt', required=False)
    parser.add_argument('-hp','--hpo', help='Human Phenotype Ontology .txt file, one HPO term per line; example: path/to/hpo.txt', required=False)
    parser.add_argument('-hpf','--hpoFile', help='Human Phenotype Ontology phenotype_to_genes file example: path/to/phenotype_to_genes.txt', required=False)
    args = vars(parser.parse_args())


    path_mae = args["mae"] # example: path/to/fraser_results_patient_x.tsv
    print("path_mae:",path_mae)
    html_template = args["template"] # example: path/to/template.html
    print("html_template:",html_template)
    path_output = args["output"] # example: path/to/patient_x_report.html
    print("path_output:",path_output)
    sample_id = args["sampleid"] # sampleId shown in report.
    print("sample_id:",sample_id)

    # load data in pandas
    mae_df = pd.read_csv(path_mae, sep="\t").rename(columns={"hgncSymbol":"gene", "pvalue":"pValue", "end":"pos"})[["gene", "chr", "pos","refAllele" ,"altAllele" ,"pValue", "padjust", "log2FC","refCount","altCount","totalCount"]]
    mae_plot_html = scatter_plot_mae(mae_df)

    # create html plots
    if args["hpo"]:
        if args["hpoFile"]:
            path_hpo_file = args["hpoFile"] # example: path/to/phenotype_to_genes.txt
            with open(args["hpo"], 'r') as hpo_file:
                hpo_terms = [line.strip().upper() for line in hpo_file]
                hpo_df = pd.read_csv(path_hpo_file, sep='\t')
                hpo_df = hpo_df[["gene_symbol","hpo_id"]][hpo_df.hpo_id.isin(hpo_terms)]
                mae_df["hpo"] = [", ".join(hpo_df.hpo_id[hpo_df.gene_symbol == gene].unique().tolist()) for gene in mae_df["gene"]]
        else:
            print("Please provide Human Phenotype Ontology phenotype_to_genes.txt file arg= -hpf --hpoFile")
            raise FileNotFoundError
    else:
        hpo_terms = False

        mae_df["hpo"] = ["" for gene in mae_df["gene"]]

    # reorder hpo to second position
    if args["mae"]:
        col = mae_df.pop('hpo')
        mae_df.insert(1, col.name, col)

    # hpo json object for active filters
    if hpo_terms:
        hpo_terms_json = json.dumps(hpo_terms)
    else:
        hpo_terms_json = json.dumps([])

    # gene enrichment analysis using gProfiler
    if args["mae"]:
        if args["hpo"]:
            gp = GProfiler(return_dataframe=True)
            gene_query = [gene.split('.')[0] for gene in mae_df['EnsemblID'][mae_df["padjust"] < 0.05 ].tolist()]
            if gene_query:
                gene_enrichment_df = gp.profile(organism='hsapiens', query=gene_query)
                gene_enrichment_html = gene_enrichment_df.to_html(index=False, classes='gene_enrichment', border=0)
            else:
                gene_enrichment_html = "No results"
        else:
            print("No Human Phenotype Ontology phenotype_to_genes.txt file provided, continue without one")
            gene_enrichment_html = "No results"
            
    # open html template
    with open(html_template, "r") as html_template_file:
           template = html_template_file.read()
    
    # create dataframe htmls
    if args["mae"]:
        if args["genepanel"]:
            gene_panel_path = args["genepanel"]
            mae_df = filter_by_gene_panel(mae_df, gene_panel_path)
            mae_df["end"] = mae_df["pos"]
            mae_df["start"] = mae_df["pos"] - 1 
            mae_df = mae_df[["gene", "chr", "pos","refAllele" ,"altAllele" ,"pValue", "padjust", "log2FC","refCount","altCount","totalCount"]]
        else:
            gene_panel_path = 'none'
            mae_df["end"] = mae_df["pos"]
            mae_df["start"] = mae_df["pos"] - 1 
            mae_df = mae_df[["gene", "chr", "pos","refAllele" ,"altAllele" ,"pValue", "padjust", "log2FC","refCount","altCount","totalCount"]]

    # default cut off column = padjust and if gene panel pValue
    cutoff_col = "padjust"

    if gene_panel_path != 'none':
        cutoff_col = "pValue"

    # create dataframe htmls
    mae_df_html = mae_df[mae_df[cutoff_col] < .99].to_html(index=False, classes='mae_table', border=0)


    # Create a Jinja2 Template object
    jinja_template = Template(template)

    # Render the template with the table
    content = jinja_template.render({"mae_table": mae_df_html,
                                     "mae_plot": mae_plot_html,
                                     "gene_enrichment": gene_enrichment_html,
                                     "patient_id": sample_id,
                                     "hpo_terms": hpo_terms_json,
                                     "gene_panel_file": gene_panel_path,
                                     "R_version" : "4.3.1",
                                     "outrider_version": "1.20.1",
                                     "fraser_version": "1.99.4",
                                     "GATK_version": "4.2.3.0",
                                     "bcftools_version": "1.19",
                                     "tMAE_version": "mumichae/tMAE@1.0.0",
                                     "filter_pval": cutoff_col,
                                     "python_version": sys.version
                                     })

    # save the html report
    with open(path_output, 'w', encoding="utf-8") as output:
           output.write(content)
