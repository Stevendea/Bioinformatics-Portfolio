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
	IndividualRNASeqProcessing $fq $gtf $ref $cores
done

# Perform multiqc on all fastqc files
multiqc -o FASTQ_DIR FASTQ_DIR/fastqc

# Generate expression matrices for all analyzed files
mkdir -p -m777 EXPRESSION_DIR/Combined_Output
output=EXPRESSION_DIR/Combined_Output
exdiras=EXPRESSION_DIR/all_samples_ST
exdirco=EXPRESSION_DIR/Combined_Output

# Create temp files of all gene_abundance.tsv's for every sample directory
i=1
add_line=""
for dir in $exdiras/*
do
	base=`basename $dir`
	if (( $i <= 1 )); 
	then
		add_line=$add_line$'Samples\t'$'\t'$base
		cut -f 1-2,7-9 $dir/gene_abundances.tsv > $exdirco/$base.tsv
		i=$((i+1))		
	else
		add_line=$add_line$'\t'$'\t'$'\t'$base
		cut -f 7-9 $dir/gene_abundances.tsv > $exdirco/$base.tsv
	fi
	
done

# Paste all temporary files together into Combined_Output
paste $exdirco/*.tsv > $exdirco/combined_expression.tsv

# Add line at the top of combined_expression.tsv detailing the different samples
# echo $add_line
echo -e "$add_line" | cat - $exdirco/combined_expression.tsv > $exdirco/combined_expression_temp.tsv && mv $exdirco/combined_expression_temp.tsv $exdirco/combined_expression.tsv

# End timing of the script
end=`date +%s`
runtime=$((end-start))
printf "\nTotal runtime of batch process script: $runtime seconds\n"