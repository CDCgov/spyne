#!/usr/bin/env nextflow

/*
========================================================================================
   staticHTML module
========================================================================================
*/

nextflow.enable.dsl = 2

process staticHTML {
    tag { 'Creating static HTML output' }
    container 'cdcgov/mira:latest'

    publishDir "${params.r}", mode: 'copy'

    input:
    val x

    output:
    path("*"), emit: dash_json

    script:
    """
    python3 ${launchDir}/bin/static_report.py ${params.r}
    #Getting file path for next step
    echo "${params.r}" > hold_path.txt
    """

    stub:
    """
    #Setting up fasta files for parquet maker in later steps
    cat ${params.outdir}/MIRA_*_amended_consensus.fasta > nt.fasta
    cat ${params.outdir}/MIRA_*_amino_acid_consensus.fasta > aa.fasta
}
