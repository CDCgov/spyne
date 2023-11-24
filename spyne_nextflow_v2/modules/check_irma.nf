#!/usr/bin/env nextflow

/*
========================================================================================
   check_irma module
========================================================================================
*/

nextflow.enable.dsl=2

process check_irma {
    tag {"checking irma for ${sample}"}

    publishDir "${params.r}/IRMA", mode: 'copy'
    
    input:
    tuple val (sample), val (irma_dir)

    output:
    tuple val (sample), val (irma_dir), path ("${sample}.irma.decision")

    script:
    """
    [ -d ${irma_dir}/amended_consensus ] &&
        [ \"\$(ls -A ${irma_dir}/amended_consensus)\" ] &&
         echo passed > ${sample}.irma.decision ||
         echo failed > ${sample}.irma.decision
    """
}

