#!/usr/bin/env nextflow

/*
========================================================================================
   pass_negatives module
========================================================================================
*/

nextflow.enable.dsl=2

process pass_negatives {
    tag {"passing negatives for ${sample}"}

    publishDir "${params.outdir}/IRMA_negative", mode: 'copy'
    
    input:
    val (sample)

    output:
    path ("*")

    script:
    """
    touch ${sample}
    """
}

