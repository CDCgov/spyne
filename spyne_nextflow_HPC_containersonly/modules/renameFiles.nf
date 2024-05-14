#!/usr/bin/env nextflow

/*
========================================================================================
   renameFiles module
========================================================================================
*/

nextflow.enable.dsl = 2

process renameFiles {
    tag { 'rename files and prep for cleanup' }

    publishDir "${params.r}",  mode: 'copy'

    input:
    path('*')

    output:
    path('*')

    script:
    '''

    fname="$(cat name.txt)"
    mkdir parq_files
    cp ./pq_files/amended_consensus.parq ./parq_files/${fname}_amended_consensus.parq
    cp ./pq_files/amino_acid_consensus.parq ./parq_files/${fname}_amino_acid_consensus.parq
    cp ./pq_files/indels.parq ./parq_files/${fname}_indels.parq
    cp ./pq_files/irma-config.parq ./parq_files/${fname}_irma-config.parq
    cp ./pq_files/samplesheet.parq ./parq_files/${fname}_samplesheet.parq
    cp ./pq_files/summary.parq ./parq_files/${fname}_summary.parq
    cp ./pq_files/variants.parq ./parq_files/${fname}_variants.parq
    cp ./pq_files/*illumina_coverage.parq ./parq_files
    cp ./pq_files/*_illumina_alleles.parq ./parq_files
    cp ./pq_files/*_reads.parq ./parq_files
    '''
}
