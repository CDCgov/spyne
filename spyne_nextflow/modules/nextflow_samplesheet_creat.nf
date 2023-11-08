#!/usr/bin/env nextflow

/*
========================================================================================
   nextflow_samplesheet_creat module
========================================================================================
*/

nextflow.enable.dsl=2

process nextflow_samplesheet_creat {
    tag {"Generating the samplesheet for nextflow"}
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path samplesheet
    path run_ID
    val experiment_type

    output:
    path "nextflow_samplesheet.csv", emit: nextflow_samplesheet

    script:
    """
    python3 ${launchDir}/spyne_nextflow/bin/nextflow_samplesheet_creat.py -s "${params.s}" -r "${params.r}" -e "${params.e}"
    """
}
