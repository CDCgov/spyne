#!/usr/bin/env nextflow

/*
========================================================================================
   dais_ribosome module
========================================================================================
*/

nextflow.enable.dsl=2

process dais_ribosome {
    tag {"Translating sequences into open reading frames (ORFs) with DAIS-Ribosome"}
    container "cdcgov/dais-ribosome:v1.3.2"

    publishDir "${params.outdir}/IRMA/dais_results", mode: 'copy'

    input:
    path input_fasta

    output:
    path ("*"), emit: dais_ribosome

    shell:
    '''
    base_name=$(basename !{input_fasta})
    dais_out="${base_name%.*}"
    ribosome --module INFLUENZA !{input_fasta} ${dais_out}.seq ${dais_out}.ins ${dais_out}.del
    '''
}
