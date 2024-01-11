Launch Directory: spyne_nextflow_HPC_containersonly

On the login node:
bash MIRA_nextflow.sh -s /scicomp/home-pure/try8/nextflow/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina/samplesheet.csv -r /scicomp/home-pure/try8/nextflow/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina -e Flu_Illumina -t

qsub:
qsub qsub_MIRA_nextflow.sh
