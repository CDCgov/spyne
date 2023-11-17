#!/usr/bin/env nextflow

/*
========================================================================================
   check_irma module
========================================================================================
*/

nextflow.enable.dsl=2

process check_irma {
    tag {"checking irma for ${irma_dir}"}

    publishDir "${params.outdir}/IRMA", mode: 'copy'
    
    input:
    val irma_dir

    output:
    tuple val (irma_dir), path ("${irma_dir}.irma.decision")

    script:
    """
    [ -d ${launchDir}/${params.outdir}/IRMA/${irma_dir}/amended_consensus ] &&
        [ \"\$(ls -A ${launchDir}/${params.outdir}/IRMA/${irma_dir}/amended_consensus)\" ] &&
         echo passed > ${irma_dir}.irma.decision ||
         echo failed > ${irma_dir}.irma.decision
    """
}

