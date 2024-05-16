#!/usr/bin/env nextflow

/*
========================================================================================
   irma module
========================================================================================
*/

nextflow.enable.dsl = 2

process irma {
    tag { "assembling genome with IRMA for ${sample }" }
    container 'cdcgov/irma-latest'

    publishDir "${params.r}/IRMA",  mode: 'copy'
    publishDir "${params.r}/logs", pattern: '*.log', mode: 'copy'

    input:
    tuple val(sample), path(subsampled_R1), path(subsampled_R2), val(irma_custom_0), val(irma_custom_1)

    output:
    tuple val(sample), path('*')

    script:
    """
    ${irma_custom_0} IRMA FLU ${subsampled_R1} ${subsampled_R2} ${sample} ${irma_custom_1} 2> ${sample}.irma.stderr.log | tee -a ${sample}.irma.stdout.log
    """
}
