#!/usr/bin/env nextflow

/*
========================================================================================
   prepEmail module
========================================================================================
*/

nextflow.enable.dsl = 2

process prepEmail {
    tag { 'Prepare email for completeion of run' }

    publishDir "${params.r}",  mode: 'copy'

    input:
    path('*')

    output:
    stdout

    script:
    """
    cp ${params.r}/*_summary.xlsx ${launchDir}/summary.xlsx
    rm ${params.r}/hold_path.txt
    rm ${params.r}/name.txt
    rm ${params.r}/temp.csv
    rm ${params.r}/run_info_setup.txt
    rm -r ${params.r}/pq_files
    """
}
