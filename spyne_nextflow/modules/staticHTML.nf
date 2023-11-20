#!/usr/bin/env nextflow

/*
========================================================================================
   staticHTML module
========================================================================================
*/

nextflow.enable.dsl=2

process staticHTML {
    tag {"Creating static HTML output"}
    publishDir "${params.outdir}", mode: 'copy'

    input:
    val x

    output:
    path ("*"), emit: dash_json

    script:
    """
    python3 ${launchDir}/spyne_nextflow/bin/static_report.py ${launchDir}/${params.outdir}
    """
}
