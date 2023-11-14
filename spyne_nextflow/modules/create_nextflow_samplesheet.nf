#!/usr/bin/env nextflow

/*
========================================================================================
   create_nextflow_samplesheet module
========================================================================================
*/

nextflow.enable.dsl=2

process create_nextflow_samplesheet {
    tag {"Generating the samplesheet for nextflow"}
    
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path samplesheet
    path run_ID
    val experiment_type

    output:
    path "nextflow_samplesheet.csv"

    script:
    """
    python3 ${launchDir}/spyne_nextflow/bin/create_nextflow_samplesheet.py -s "${params.s}" -r "${params.r}" -e "${params.e}"
    """
}
