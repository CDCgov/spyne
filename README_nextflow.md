# Versions on CDCgov/spyne at nextflow (github.com)
* spyne_nextflow: version 1; publish directory: results; run locally under mira-dev conda env
* spyne_nextflow_v2: publish directory: runpath; added metrics files; run locally under mira-dev conda env
* spyne_nextflow_v3_containeronly: run locally under containers only
* spyne_nextflow_HPC_containersonly: run on HPC under containers only

All pipelines are executed using the command line specified in the run_command.md file.

# Changes made to environment.yml
* removed: java-jdk=7.0.91=1
* changed: openjdk=11.0.13

# HPC:
* Pull and run docker images in singularity: add `-profile singularity` in the nextflow command line
* Run the pipeline in the login node: add `-profile singularity,local` in the nextflow command line
* Run the pipeline in the computing nodes with sge executor: add `-profile singularity,rosalind` in the nextflwo command line
* Submit all jobs to sge: run `qsub qsub_qsub_MIRA_nextflow.sh`
* dais-ribosome container: 
writing permission denied - `/dais-ribosome/workdir` and `dais-ribosome/lib/sswsort/workdir`
* bbtools: docker container `staphb/bbtools:39.01`
* MIRA_nextflow.sh: `-t` only tar part of the results to facilitate the next run
* Template config files that allow pipelines to be ran on rosalind located in `/scicomp/reference/nextflow/configs/`
* Build nextflow pipeline with nf-core style format: `https://training.biotech.cdc.gov/build_nfcore_pipeline/`

# Channels:
* Input_ch.view()

[sample_ID:sample_1, fastq_1:/home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_1_R1.fastq.gz, fastq_2:/home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_1_R2.fastq.gz, sample_type:Test]
[sample_ID:sample_2, fastq_1:/home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_2_R1.fastq.gz, fastq_2:/home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_2_R2.fastq.gz, sample_type:Test]
[sample_ID:sample_3, fastq_1:/home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_3_R1.fastq.gz, fastq_2:/home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_3_R2.fastq.gz, sample_type:Test]
[sample_ID:sample_4, fastq_1:/home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_4_R1.fastq.gz, fastq_2:/home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_4_R2.fastq.gz, sample_type:Test]

* Irma_chemistry_ch.view()
  
[sample_ID:sample_1, irma_custom_0:, irma_custom_1:, subsample:100000]
[sample_ID:sample_3, irma_custom_0:, irma_custom_1:, subsample:100000]
[sample_ID:sample_4, irma_custom_0:, irma_custom_1:, subsample:100000]
[sample_ID:sample_2, irma_custom_0:, irma_custom_1:, subsample:100000]

* subsample_ch.view()
  
[sample_1, /home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_1_R1.fastq.gz, /home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_1_R2.fastq.gz, 100000]
[sample_3, /home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_3_R1.fastq.gz, /home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_3_R2.fastq.gz, 100000]
[sample_4, /home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_4_R1.fastq.gz, /home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_4_R2.fastq.gz, 100000]
[sample_2, /home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_2_R1.fastq.gz, /home/try8/FLU_SC2_SEQUENCING/tiny_test_run_flu_illumina/fastqs/sample_2_R2.fastq.gz, 100000]

* new_ch4.view()
  
[sample_ID:sample_1, subsampled_R1:/home/try8/work/7e/489bb2a917bfde6d888540a9d36eca/sample_1_subsampled_R1.fastq, subsampled_R2:/home/try8/work/7e/489bb2a917bfde6d888540a9d36eca/sample_1_subsampled_R2.fastq]
[sample_ID:sample_4, subsampled_R1:/home/try8/work/b3/87ed31622678660dc5f1f986da0b44/sample_4_subsampled_R1.fastq, subsampled_R2:/home/try8/work/b3/87ed31622678660dc5f1f986da0b44/sample_4_subsampled_R2.fastq]
[sample_ID:sample_3, subsampled_R1:/home/try8/work/6a/311f8a8c829dca4978372faca48e29/sample_3_subsampled_R1.fastq, subsampled_R2:/home/try8/work/6a/311f8a8c829dca4978372faca48e29/sample_3_subsampled_R2.fastq]
[sample_ID:sample_2, subsampled_R1:/home/try8/work/26/d6f146260d0c73df09d110b297e0f4/sample_2_subsampled_R1.fastq, subsampled_R2:/home/try8/work/26/d6f146260d0c73df09d110b297e0f4/sample_2_subsampled_R2.fastq]

* Irma_ch
  
[sample_1, /home/try8/work/6e/0761b5c40d297e6ffb6c6fbcb9fd3f/sample_1_subsampled_R1.fastq, /home/try8/work/6e/0761b5c40d297e6ffb6c6fbcb9fd3f/sample_1_subsampled_R2.fastq, , ]
[sample_4, /home/try8/work/e7/e20bd7f01948826235b82d0f92737c/sample_4_subsampled_R1.fastq, /home/try8/work/e7/e20bd7f01948826235b82d0f92737c/sample_4_subsampled_R2.fastq, , ]
[sample_3, /home/try8/work/b2/4b5c762e07849fa60923412425e548/sample_3_subsampled_R1.fastq, /home/try8/work/b2/4b5c762e07849fa60923412425e548/sample_3_subsampled_R2.fastq, , ]
[sample_2, /home/try8/work/b6/1d5bfc6871c9691da2115f3b671363/sample_2_subsampled_R1.fastq, /home/try8/work/b6/1d5bfc6871c9691da2115f3b671363/sample_2_subsampled_R2.fastq, , ]

* checkirma_ch
  
/home/try8/work/de/97c53c7feb4cd3ccec6d0448f8975c/sample_4
/home/try8/work/76/951f61fd4de19712087e0becd12c28/sample_1
/home/try8/work/86/bd1040197009e5398c57089d6faee7/sample_3
/home/try8/work/5b/d359bcb7691fb158edd8bc855e513d/sample_2

* passedSamples.collect()
  
[/home/try8/spyne_nextflow_v3_containersonly/work/4a/adbdc139fc092371819d428adec7b8/sample_2, /home/try8/spyne_nextflow_v3_containersonly/work/e1/ef562f39eff36cefc272cc369a377d/sample_1, /home/try8/spyne_nextflow_v3_containersonly/work/1d/875883912e9e534698066f9b9bad25/sample_4, /home/try8/spyne_nextflow_v3_containersonly/work/4c/43b73ecd3713ac878c84aff2375b23/sample_3]




