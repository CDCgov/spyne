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
    sed 's/[>,]//g' ${params.r}/assembled_samples.txt
    cp ${params.r}/assembled_samples.txt ${launchDir}/assembled_samples.txt
    rm ${params.r}/hold_path.txt
    rm ${params.r}/name.txt
    rm ${params.r}/temp.csv
    rm ${params.r}/run_info_setup.txt
    rm -r ${params.r}/pq_files
    """
}
