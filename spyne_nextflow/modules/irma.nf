#!/usr/bin/env nextflow

/*
========================================================================================
   irma module
========================================================================================
*/

nextflow.enable.dsl=2

process irma {
    tag {"assembling genome with IRMA for ${sample}"}
    container "cdcgov/irma:v1.1.1"

    cpus 14

    publishDir "${params.outdir}/IRMA", mode: 'copy'
    publishDir "${params.outdir}/logs", pattern: "*.log", mode: 'copy'

    input:
    tuple val(sample), path(subsampled_R1), path(subsampled_R2), val(irma_custom_0), val(irma_custom_1)

    output:
    val (sample), emit:irma_dir
    path "*"
    path "${sample}.irma.stdout.log", emit: irma_log_out
    path "${sample}.irma.stderr.log", emit: irma_log_err   

    script:
    """
    ${irma_custom_0}IRMA FLU ${subsampled_R1} ${subsampled_R2} ${sample} ${irma_custom_1} 2> ${sample}.irma.stderr.log | tee -a ${sample}.irma.stdout.log
    """
}
