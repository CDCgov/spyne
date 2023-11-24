./nextflow /home/try8/spyne_nextflow_v2/workflow/illumina_influenza_nextflow.nf \
	--s /home/try8/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina/samplesheet.csv \
	--r /home/try8/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina \
	--e illumina_influenza \
	-c spyne_nextflow_v2/workflow/nextflow.config \
	-with-trace /home/try8/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina/trace.txt \
	-with-timeline /home/try8/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina/timeline.html \
	-with-report /home/try8/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina/report.html \
  -with-dag /home/try8/FLU_SC2_SEQUENCING_nextflow/tiny_test_run_flu_illumina/dag.png
