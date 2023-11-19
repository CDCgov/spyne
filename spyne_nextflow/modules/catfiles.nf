#!/usr/bin/env nextflow

/*
========================================================================================
   catfiles module
========================================================================================
*/

nextflow.enable.dsl=2

process catfiles {
    tag {"Collecting consensus genomes"}

    publishDir "${params.outdir}/IRMA/dais_results", mode: 'copy'

    input:
    val samplelist

    output:
    path ("*")

    script:
    def foldersString = samplelist.join(' ')
    """
    IFS=' ' read -r -a folderArray <<< "$foldersString"
    > DAIS_ribosome_input.fasta
    for folder in "\${folderArray[@]}"; do
        cat ${launchDir}/${params.outdir}/IRMA/\$folder/amended_consensus/* >> DAIS_ribosome_input.fasta
    done
    """
}
