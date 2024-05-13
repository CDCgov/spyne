#!/usr/bin/env nextflow

/*
========================================================================================
   parquetMaker module
========================================================================================
*/

nextflow.enable.dsl = 2

process parquetMaker {
    tag { 'Creating paquet output' }
    container 'cdcgov/spyne-dev:v1.2.0'

    publishDir "${params.r}",  mode: 'copy'

    input:
    val run_path

    output:
    path('*'), emit: summary_parq

    beforeScript 'mkdir pq_files'
    afterScript 'mv *parq ./pq_files'

    script:
    """
    #can I add notes?
    cat ${params.r}/amended_consensus.fasta ${params.r}/failed_amended_consensus.fasta > nt.fasta
    cat ${params.r}/amino_acid_consensus.fasta ${params.r}/failed_amino_acid_consensus.fasta> aa.fasta
    python3 ${launchDir}/bin/parquet_maker.py -f nt.fasta -o amended_consensus.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -f aa.fasta -o amino_acid_consensus.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/samplesheet.csv -o samplesheet.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/*minorindels.xlsx -o indels.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/*minorvariants.xlsx -o variants.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/*summary.xlsx -o summary.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -p ${params.r} -r ${run_path}
    cat ${params.r}/IRMA/*/logs/run_info.txt > run_info_setup.txt
    head -n 65 run_info_setup.txt > run_info.txt
    python3 ${launchDir}/bin/parquet_maker.py -f run_info.txt -o irma-config.parq -r ${run_path}
    grep ">" ${params.r}/amended_consensus.fasta > assembled_samples.txt
    echo "${run_path}" > name.txt
    """
}
