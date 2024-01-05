#!/usr/bin/env nextflow

/*
========================================================================================
   staticHTML module
========================================================================================
*/

nextflow.enable.dsl=2

process staticHTML {
    tag {"Creating static HTML output"}
    container "spyne:latest"

    publishDir "${params.r}", mode: 'copy'

    input:
    val x
    path runpath

    output:
    path ("*")

    script:
    """
    python3 /spyne/workflow/scripts/static_report.py ${params.r}
    """ 
}
