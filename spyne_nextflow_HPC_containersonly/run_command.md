Directory: spyne_nextflow_HPC

On the login node:
bash MIRA_nextflow.sh -s /scicomp/home-pure/try8/nextflow/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina/samplesheet.csv -r /scicomp/home-pure/try8/nextflow/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina -e Flu_Illumina -c True

qsub:
qsub qsub_MIRA_nextflow.sh