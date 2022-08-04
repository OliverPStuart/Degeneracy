#!/bin/bash
#pipeline for getting 4fold degenerate sites
#from gff and fasta, using python, awk, and bedtools
#Tyler Kent
#14 March 2017

###################################
# SET UP PATHS
#
# This is the only portion of the
# pipeline that needs to be
# adjusted. Assume gff is gzipped.
###################################

working_dir=/Volumes/Alter/LHISI
gff=${working_dir}/References/Annotation/LHISI_Scaffold_Assembly.annotation.gff.gz
fasta=${working_dir}//References/LHISI_Scaffold_Assembly.fasta
CDSbedout=${working_dir}/Analyses/DeleteriousMutations/LHISI_cds.bed
fastaCDSout=${working_dir}/Analyses/DeleteriousMutations/LHISI_cds.tab
fourfoldbedout=${working_dir}/Analyses/DeleteriousMutations/LHISI_degenerate

###################################
# STEP 1: GET BED FILE OF CDS AND
# SHIFT TO MATCH PHASE
#
# CDS sequence in GFF format
# contains sections of translated
# sequence, with phase info, which
# indicates the start of the first
# codon.
###################################

bash gff2bed.sh ${gff} CDS | awk -f gffphaseshift.awk - > ${CDSbedout}

###################################
# STEP 2: USE BED FILE AND FASTA
# TO GET FILE OF POS AND SEQUENCE
#
# Use bedtools to get relevant 
# fasta sequence into useable
# format.
###################################

bedtools getfasta -s -tab -name -fi ${fasta} -bed ${CDSbedout} > ${fastaCDSout}

###################################
# STEP 3: KEEP ONLY LONGEST 
# ISOFORM
#
# Drop all alternate isoforms but
# the longest.
###################################

# DEPRECATED--DONT DO THIS STEP
###python keep_longest_isoform.py -i ${fastaCDSout} -o ${longestonly}

###################################
# STEP 4: CONVERT FASTA DNA
# SEQUENCE INTO CODONS, FLIP FOR
# PHASE, AND REPORT 4FOLD SITES
#
# Using python and a codon table
###################################

python degeneracy.py -i ${fastaCDSout} -o ${fourfoldbedout}

###################################
# STEP 5: SORT OUTPUT
#
# Just need to sort the python 
# output like you would a normal
# bed file, and drop mistake dups.
###################################

# DEPRECATED--DONT DO THIS STEP
#cat ${fourfoldbedout}.bed | sort -k1,1 -k2,2n | uniq > ${fourfoldbedout}.sorted.bed
