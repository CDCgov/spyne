#!/bin/bash
#$ -o $1/nextflow.out
#$ -e $1/nextflow.err
#$ -N Illumina_influenza_nextflow
#$ -pe smp 2
#$ -l h_rt=72:00:00
#$ -l h_vmem=32G
#$ -q flu.q
#$ -cwd
#$ -V

# Experiment type options: Flu-ONT, SC2-Spike-Only-ONT, Flu_Illumina, SC2-Whole-Genome-ONT, SC2-Whole-Genome-Illumina
# Primer Schema options: articv3, articv4, articv4.1, articv5.3.2, qiagen, swift, swift_211206

source /etc/profile
RUNPATH='/scicomp/scratch/xpa3/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina'
TAR=True

# Archive previous run using the summary.xlsx file sent in email
if [ -f "./summary.xlsx" ] && [ -n "${TAR}" ]; then
	tar --remove-files -czf ${RUNPATH}/previous_run_$(date -d @$(stat -c %Y ./summary.xlsx) "+%Y%b%d-%H%M%S").tar.gz ${RUNPATH}/*html ${RUNPATH}/*fasta ${RUNPATH}/*txt
fi

# Run nextflow
module load nextflow/23.10.0
nextflow run ./workflow/illumina_influenza_nextflow.nf \
	--s "$RUNPATH"/samplesheet.csv \
	--r "$RUNPATH" \
	--e Flu_Illumina \
	-c ./nextflow.config \
	-profile singularity,rosalind
