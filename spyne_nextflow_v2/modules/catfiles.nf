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
    def foldersString = irma_out.join(' ')
    """
    IFS=' ' read -r -a folderArray <<< "$foldersString"
    > DAIS_ribosome_input.fasta
    for folder in "\${folderArray[@]}"; do
        cat \$folder/amended_consensus/* >> DAIS_ribosome_input.fasta
    done
    """
}
