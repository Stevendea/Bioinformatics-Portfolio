#!/bin/bash
# Group RNA-seq processing script version 1.0
# Author: Steven Dea
# Date Modified: 5/20/20

# This script will iterate through all fastq files present in the directory it is called in
# and run the individual RNA-seq script.
# Once all files have been processed, it will perform multiqc on all fastqc files,
# Merge all HISAT2 aligned BAM files, and generate expression matrices for FPKM and TPM
# using stringtie_expression_matrix.pl from Griffith Lab
# This script has 3 command line arguments:
# 1. Path to the .gtf file for Hg38 ($1)
# 2. Path to the .fa reference genome file for Hg38 ($2)
# 3. # of threads/cores to use for processing ($3)

# Begin timing of the script
start=`date +%s`

# Assigns first positional paramter to the variable gtf
gtf=${1?Error: no .gtf file specified}

# Assigns second positional paramter to the variable ref
ref=${2?Error: no reference genome .fa specified}

# Assigns third positional parameter to variable cores, if none is specified default to 1
cores=${3:-1}

# Iterate through current working directory fq files
for fq in *.fastq
do
	./IndividualRNASeqProcessing $fq $gtf $ref $cores
done

# Perform multiqc on all fastqc files
multiqc -o FASTQ_DIR FASTQ_DIR/fastqc

# # Generate expression matrices for all analyzed files - CURRENTLY WORKS BUT NO GENE NAMES!!!
# exdiras=EXPRESSION_DIR/all_samples_ST
# exdirlist=`ls -dm $exdiras/*/ | tr -d '[:space:]'`
# echo $exdirlist

# mkdir -p -m777 EXPRESSION_DIR/Combined_Output
# output=EXPRESSION_DIR/Combined_Output

# # TPM
# stringtie_expression_matrix.pl --expression_metric=TPM --result_dirs="$exdirlist" --transcript_matrix_file=$output/transcript_tpm_all_samples.tsv --gene_matrix_file=$output/gene_tpm_all_samples.tsv
# # FPKM
# stringtie_expression_matrix.pl --expression_metric=FPKM --result_dirs="$exdirlist" --transcript_matrix_file=$output/transcript_fpkm_all_samples.tsv --gene_matrix_file=$output/gene_fpkm_all_samples.tsv
# # Transcript Coverage
# stringtie_expression_matrix.pl --expression_metric=Coverage --result_dirs="$exdirlist" --transcript_matrix_file=$output/transcript_coverage_all_samples.tsv --gene_matrix_file=$output/gene_coverage_all_samples.tsv

# End timing of the script
end=`date +%s`
runtime=$((end-start))
printf "\nTotal runtime of batch process script: $runtime seconds\n"