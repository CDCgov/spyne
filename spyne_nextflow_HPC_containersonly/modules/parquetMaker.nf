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
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/nt.fasta -o amended_consensus.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/aa.fasta -o amino_acid_consensus.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/samplesheet.csv -o samplesheet.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/*minorindels.xlsx -o indels.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/*minorvariants.xlsx -o variants.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/*summary.xlsx -o summary.parq -r ${run_path}
    python3 ${launchDir}/bin/parquet_maker.py -p ${params.r} -r ${run_path}
    cat ${params.r}/IRMA/*/logs/run_info.txt > run_info_setup.txt
    head -n 65 run_info_setup.txt > run_info.txt
    python3 ${launchDir}/bin/parquet_maker.py -f run_info.txt -o irma-config.parq -r ${run_path}
    echo "${run_path}" > name.txt
    """
}
