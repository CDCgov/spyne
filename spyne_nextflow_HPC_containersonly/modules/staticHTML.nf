#!/usr/bin/env nextflow

/*
========================================================================================
   staticHTML module
========================================================================================
*/

nextflow.enable.dsl = 2

process staticHTML {
    tag { 'Creating static HTML output' }
    container 'cdcgov/mira:latest'

    publishDir "${params.r}", mode: 'copy'

    input:
    val x

    output:
    path("*"), emit: dash_json

    script:
    """
    python3 ${launchDir}/bin/static_report.py ${params.r}
    echo "${params.r}" > hold_path.txt
    """
}
