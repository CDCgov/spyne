#!/usr/bin/env nextflow

/*
========================================================================================
   staticHTML module
========================================================================================
*/

nextflow.enable.dsl=2

process staticHTML {
    tag {"Creating static HTML output"}
    container "cdcgov/spyne:latest"

    publishDir "${params.r}", mode: 'copy'

    input:
    val x

    output:
    path ("*"), emit: dash_json

    script:
    """
    python3 /spyne/workflow/scripts/static_report.py ${params.r}
    """
}
