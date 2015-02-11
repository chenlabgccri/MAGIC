function [p1,p0,mod_score,adj_mat] = ...
MAGIC(data,group,bonf,equ_sam_size,p_cutoff,mod_score_cutoff,output_filename)

% MATLAB tool for modulated gene/gene set interaction (MAGIC) analysis
% 
% 
% MAGIC(DATA,GROUP,BONF,EQU_SAM_SIZE,P_CUTOFF,MOD_SCORE_CUTOFF,OUTPUT_FILENAME)
% identifies differentially correlated gene (or gene set) pairs modulated
% by states of a modulator; i.e., pair of genes that is correlated
% specifically in one state of the modulator (M). All possible combinations
% of genes deposited in DATA are tested. Take pair of gene i and j for
% example, correlation coefficients of gene i and j are separately
% calculated in samples with M=1 and samples with M=0. The correlation
% coefficients are Fisher transformed to a sample-size-free domain and
% tested for significance of their difference in the absolute manner (the
% modulation test). To ensure biologically meaningful change between the
% correlation coefficients, inverse Fisher transformation is utilized to
% convert the Fisher transformed coefficients back to the domain with a
% user-defined equivalent sample size. The modulation score measures the
% difference of transformed correlation coefficients. Gene (or gene set)
% pairs that meet the criteria on p-value from modulation test and
% modulation score are defined as modulated interaction pairs. The MAGIC
% tool outputs three matrices: modulation p-values, modulation scores, and
% adjacency matrix of the modulated interaction network, as well as a .txt
% file that can be used to generate the modulated interaction network by
% the Cytoscape software.
% 
% 
% Description of the input parameters:
% 
% DATA is a K-by-N numeric matrix (in double precision), which contains the
% expression profiles of K genes (or enrichment scores of K gene sets) in N
% samples. DATA should not contain NaNs.
% 
% GROUP is an N-length numeric vector that defines binary states of the
% modulator in N samples. GROUP can contain only 0s and 1s.
% 
% BONF is set as 1 to perform Bonferroni correction to the number of
% testing (nchoosek(K,2)). To analyze raw p-values, BONF should be set to
% 0. Suggested setting: 1
% 
% EQU_SAM_SIZE is a numeric value denoting user-assigned sample size at
% which correlation coefficients from two sample sizes (i.e., number of
% samples with M=1 and M=0) are compared; that is, the modulation scores
% are calculated at the sample size of EQU_SAM_SIZE. Suggested setting:
% average of number of samples with M=1 and M=0
% 
% P_CUTOFF is the threshold on raw (or Bonferroni corrected, when BONF = 1)
% p-value to define "statistically" significant modulated interaction.
% Suggested setting: 0.05
% 
% MOD_SCORE_CUTOFF is the threshold on modulation score to define
% "biologically" significant modulated interaction. MOD_SCORE_CUTOFF must
% be a positive numeric value. Suggested setting: 0.6
% 
% OUTPUT_FILENAME is a string specifying a filename for the output .txt
% file. If set as 'NA', no output txt file will be generated.
% 
% 
% Description of the outputs:
% 
% P1 is a K-by-K symmetric matrix, with elements of p-value from the
% modulation test. Significant P1(i,j) (typically < 0.05) means that genes
% i and j are strongly (either positively or negatively) correlated
% specifically in M=1 samples.
% 
% P0 is a K-by-K symmetric matrix, denoting the significance of strong
% correlation specifically in M=0 samples.
% 
% MOD_SCORE is a K-by-K symmetric matrix of modulation scores. Larger
% positive elements have stronger correlation in M=1 samples compared to
% M=0.
% 
% ADJ_MAT is a K-by-K symmetric adjacency matrix, of which a non-zero
% element ADJ_MAT(i,j) denotes a modulated interaction pair of i and j
% (i.e., the i-j edge in the modulated interaction network.
% 
% When output_filename is specified with any string except for 'NA', a
% Cytoscape compatible 'output_filename.txt' will be generated. The .txt
% file can be imported to Cytoscape for construction, visualization, and
% analyses of the modulated interaction network.
% 
% 
% Reference: The MAGIC tool is for academic purposes only and all rights
% are reserved. To reference the MAGIC algorithm or the tool, please cite
% the paper: "Modulation analysis reveals a survival effect of estrogen
% receptor-modulated interaction between TGFb and NFkB gene sets in breast
% cancer" by Hsiao and Chiu et al. Mathematical details and biological
% applications of MAGIC can be found in this paper. For questions and
% comments regarding the MAGIC tool, please contact us at
% f99945006@ntu.edu.tw
% 
% Enjoy!

tic

num_gene = size(data,1);
sam1 = find(group==1);
sam0 = find(group==0);
num_sam1 = length(sam1);
num_sam0 = length(sam0);

% calculation of raw correlation coefficients
[Corr1 Corr1_p] = corrcoef(data(:,sam1)');
z1 = 0.5*log((1+Corr1)./(1-Corr1));
CS1 = sqrt(num_sam1-3)*z1; % Fisher-transformed correlation

[Corr0 Corr0_p] = corrcoef(data(:,sam0)');
z0 = 0.5*log((1+Corr0)./(1-Corr0));
CS0 = sqrt(num_sam0-3)*z0; % Fisher-transformed correlation

corr_diff_fisher = abs(CS1) - abs(CS0);

% p-value from the modulation test p-value
p1 = 1-(0.5+erf(corr_diff_fisher/2)-0.5*sign(corr_diff_fisher).*erf(corr_diff_fisher/2).*erf(corr_diff_fisher/2)); % right-tail
p0 = (0.5+erf(corr_diff_fisher/2)-0.5*sign(corr_diff_fisher).*erf(corr_diff_fisher/2).*erf(corr_diff_fisher/2)); % left-tail

% Bonferroni correction
if bonf==1
    p1 = p1*nchoosek(num_gene,2);
    p0 = p0*nchoosek(num_gene,2);
end

p1(p1>1) = 1;
p0(p0>1) = 1;

% inverse Fisher transformation to N = equ_sam_size %
z1_b = 1/sqrt(equ_sam_size-3)*CS1;
r1_b = (exp(2*z1_b)-1)./(exp(2*z1_b)+1);
z0_b = 1/sqrt(equ_sam_size-3)*CS0;
r0_b = (exp(2*z0_b)-1)./(exp(2*z0_b)+1);
mod_score = abs(r1_b)-abs(r0_b);

% identification of M=1 specific interaction pairs
[row1 col1] = find((p1<=p_cutoff).*(mod_score>=mod_score_cutoff).*(triu(ones(num_gene),1)));
id1 = find((p1<=p_cutoff).*(mod_score>=mod_score_cutoff).*(triu(ones(num_gene),1)));

% identification of M=0 specific interaction pairs
[row0 col0] = find((p0<=p_cutoff).*(mod_score<=-mod_score_cutoff).*(triu(ones(num_gene),1)));
id0 = find((p0<=p_cutoff).*(mod_score<=-mod_score_cutoff).*(triu(ones(num_gene),1)));

% adjacency matrix
% 2: M=1 specific positive correlation; 1: M=1 specific negative correlation
% -1: M=0 specific positive correlation; -2: M=0 specific negative correlation
adj_mat = zeros(num_gene);
adj_mat(id1(Corr1(id1)>0)) = 2;
adj_mat(id1(Corr1(id1)<0)) = 1;
adj_mat(id0(Corr0(id0)>0)) = -1;
adj_mat(id0(Corr0(id0)<0)) = -2;
for i=1:(num_gene-1)
    adj_mat((i+1):num_gene,i) = adj_mat(i,(i+1):num_gene);
end

time_used = toc;

% export Cytoscape .txt file
if ~strcmp(output_filename,'NA')
    fid = fopen(sprintf('%s.txt',output_filename),'w');
    fprintf(fid, ['Gene1' '\t' 'Gene2' '\t' sprintf('Raw corr in M=1 (N=%s)',num2str(num_sam1)) ...
        '\t' sprintf('Raw corr in M=0 (N=%s)',num2str(num_sam0))  '\t' 'P-value' '\t' ...
        sprintf('Modulation score (N=%s)',num2str(equ_sam_size)) '\n']);
    fprintf(fid, '%d \t %d \t %.3f \t %.3f \t %.2e \t %.3f \n', [col1 row1 Corr1(id1) Corr0(id1) p1(id1) mod_score(id1)]');
    fprintf(fid, '%d \t %d \t %.3f \t %.3f \t %.2e \t %.3f \n', [col0 row0 Corr1(id0) Corr0(id0) p0(id0) mod_score(id0)]');
    fclose(fid);
    disp(sprintf('\n\nSuccess! MAGIC analysis comes true!\n\n%s.txt has been generated.\n\nComputation time: %.2f seconds.\n',output_filename,time_used));
else
    disp(sprintf('\n\nSuccess! MAGIC analysis comes true!\n\nComputation time: %.2f seconds.\n',time_used));
end

