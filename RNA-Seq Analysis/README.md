This Directory contains work regarding analysis of RNA-Seq data. To begin, it contains a data analysis pipeline bash script to analyze raw fastq files
by first running fastqc, then hisat2 alignment, then sorting and indexing of aligned bam files, then performing stringtie to generate expression data to be analyzed
later, and lastly htseq-count to get raw counts of transcripts for later analysis.
