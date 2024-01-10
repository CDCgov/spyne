#!/usr/bin/env nextflow

/*
========================================================================================
   catfiles module
========================================================================================
*/

nextflow.enable.dsl=2

process catfiles {
    tag {"Collecting consensus genomes"}

    publishDir "${params.r}/IRMA/dais_results", mode: 'copy'

    input:
    val irma_out

    output:
    path ("DAIS_ribosome_input.fasta")

    script:
    def folderPaths = irma_out.collect { "$it/amended_consensus/*" }.join(" ")
    """
    cat $folderPaths > DAIS_ribosome_input.fasta
    """
}
