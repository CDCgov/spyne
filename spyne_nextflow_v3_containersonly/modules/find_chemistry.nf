#!/usr/bin/env nextflow

/*
========================================================================================
   find_chemistry module
========================================================================================
*/

nextflow.enable.dsl=2

process find_chemistry {
    tag {"finding chemistry parameters for "}

    publishDir "${params.r}/IRMA", mode: 'copy'

    input:
    tuple val (sample), path (fastq), path (runid)

    output:
    path "${sample}_chemistry.csv"

    script:
    """
    python3 ${launchDir}/bin/find_chemistry.py -s "${sample}" -q "${fastq}" -r "${runid}"
    """
}
