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
    rm ${launchDir}/summary.xlsx
    cp ${params.r}/*_summary.xlsx ${launchDir}/summary.xlsx
    """
}
