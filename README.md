# MAGIC
MATLAB tool for modulated gene/gene set interaction (MAGIC) analysis

MAGIC(DATA,GROUP,BONF,EQU_SAM_SIZE,P_CUTOFF,MOD_SCORE_CUTOFF,OUTPUT_FILENAME) identifies differentially correlated gene (or gene set) pairs modulated by states of a modulator; i.e., pair of genes that is correlated specifically in one state of the modulator (M). All possible combinations of genes deposited in DATA are tested. Take pair of gene i and j for example, correlation coefficients of gene i and j are separately calculated in samples with M=1 and samples with M=0. The correlation coefficients are Fisher transformed to a sample-size-free domain and tested for significance of their difference in the absolute manner (the modulation test). To ensure biologically meaningful change between the correlation coefficients, inverse Fisher transformation is utilized to convert the Fisher transformed coefficients back to the domain with a user-defined equivalent sample size. The modulation score measures the difference of transformed correlation coefficients. Gene (or gene set) pairs that meet the criteria on p-value from modulation test and modulation score are defined as modulated interaction pairs. The MAGIC tool outputs three matrices: modulation p-values, modulation scores, and adjacency matrix of the modulated interaction network, as well as a .txt file that can be used to generate the modulated interaction network by the Cytoscape software.

Description of the input parameters:

DATA is a K-by-N numeric matrix (in double precision), which contains the expression profiles of K genes (or enrichment scores of K gene sets) in N samples. DATA should not contain NaNs.

GROUP is an N-length numeric vector that defines binary states of the modulator in N samples. GROUP can contain only 0s and 1s.

BONF is set as 1 to perform Bonferroni correction to the number of testing (nchoosek(K,2)). To analyze raw p-values, BONF should be set to 0. Suggested setting: 1

EQU_SAM_SIZE is a numeric value denoting user-assigned sample size at which correlation coefficients from two sample sizes (i.e., number of samples with M=1 and M=0) are compared; that is, the modulation scores are calculated at the sample size of EQU_SAM_SIZE. Suggested setting: average of number of samples with M=1 and M=0

P_CUTOFF is the threshold on raw (or Bonferroni corrected, when BONF = 1) p-value to define "statistically" significant modulated interaction. Suggested setting: 0.05

MOD_SCORE_CUTOFF is the threshold on modulation score to define "biologically" significant modulated interaction. MOD_SCORE_CUTOFF must be a positive numeric value. Suggested setting: 0.6

OUTPUT_FILENAME is a string specifying a filename for the output .txt file. If set as 'NA', no output txt file will be generated.

Description of the outputs:

P1 is a K-by-K symmetric matrix, with elements of p-value from the modulation test. Significant P1(i,j) (typically < 0.05) means that genes i and j are strongly (either positively or negatively) correlated specifically in M=1 samples.

P0 is a K-by-K symmetric matrix, denoting the significance of strong correlation specifically in M=0 samples.

MOD_SCORE is a K-by-K symmetric matrix of modulation scores. Larger positive elements have stronger correlation in M=1 samples compared to M=0.

ADJ_MAT is a K-by-K symmetric adjacency matrix, of which a non-zero element ADJ_MAT(i,j) denotes a modulated interaction pair of i and j (i.e., the i-j edge in the modulated interaction network.

When output_filename is specified with any string except for 'NA', a Cytoscape compatible 'output_filename.txt' will be generated. The .txt file can be imported to Cytoscape for construction, visualization, and analyses of the modulated interaction network.

Reference: The MAGIC tool is for academic purposes only and all rights are reserved. To reference the MAGIC algorithm or the tool, please cite the paper: Hsiao and Chiu et al. Differential network analysis reveals the genome-wide landscape of estrogen receptor modulation in hormonal cancers. Scientific Reports. 2016;6:23035. doi:10.1038/srep23035. Mathematical details and biological applications of MAGIC can be found in this paper.

Enjoy!
