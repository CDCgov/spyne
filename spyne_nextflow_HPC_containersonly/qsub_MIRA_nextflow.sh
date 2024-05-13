#!/bin/bash

source /etc/profile

#$ -o nextflow.out
#$ -e nextflow.err
#$ -N Illumina_influenza_nextflow
#$ -pe smp 2
#$ -l h_rt=72:00:00
#$ -l h_vmem=32G
#$ -q flu.q
#$ -cwd
#$ -V

bash MIRA_nextflow.sh \
	-s /scicomp/scratch/xpa3/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina/samplesheet.csv \
	-r /scicomp/scratch/xpa3/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina \
	-e Flu_Illumina \
	-t
