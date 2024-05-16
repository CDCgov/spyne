#!/usr/bin/env nextflow

/*
========================================================================================
   create_nextflow_samplesheet module
========================================================================================
*/

nextflow.enable.dsl = 2

process create_nextflow_samplesheet {
    tag { 'Generating the samplesheet for nextflow' }
    container 'cdcgov/spyne:latest'

    publishDir "${params.r}", mode: 'copy'

    input:
    path samplesheet
    path run_ID
    val experiment_type

    output:
    path 'nextflow_samplesheet.csv'

    script:
    """
    #Removing if previous made
    if [ -e ${launchDir}/summary.xlsx]; then
    rm ${launchDir}/summary.xlsx
    fi
    #Set up so that email sends whether workflow finishes or not
    cp ${launchDir}/bin/assets/summary.xlsx ${launchDir}/summary.xlsx
    #Create nf samplesheet
    python3 ${launchDir}/bin/create_nextflow_samplesheet.py -s "${params.s}" -r "${params.r}" -e "${experiment_type}"
    """
}
