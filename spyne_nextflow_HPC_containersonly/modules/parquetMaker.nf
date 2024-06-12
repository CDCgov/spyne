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

    publishDir "${params.r}/parq_files", pattern: '*.parq',  mode: 'copy'

    input:
    val x
    val run_path

    output:
    path('*'), emit: summary_parq

    script:
    def run_name = run_path.getBaseName()

    """
    if [ -f  ${params.r}/failed_amended_consensus.fasta ]; then
    cat ${params.r}/MIRA_${run_name}_amended_consensus.fasta ${params.r}/MIRA_${run_name}_failed_amended_consensus.fasta > nt.fasta
    fi
    if [ ! -f  ${params.r}/failed_amended_consensus.fasta ]; then
    cat ${params.r}/MIRA_${run_name}_amended_consensus.fasta > nt.fasta
    fi
    if [ -f  ${params.r}/failed_amino_acid_consensus.fasta ]; then
    cat ${params.r}/MIRA_${run_name}_amino_acid_consensus.fasta ${params.r}/MIRA_${run_name}_amino_acid_consensus.fasta > aa.fasta
    fi
    if [ ! -f  ${params.r}/failed_amino_acid_consensus.fasta ]; then
    cat ${params.r}/MIRA_${run_name}_amino_acid_consensus.fasta > aa.fasta
    fi
    python3 ${launchDir}/bin/parquet_maker.py -f nt.fasta -o ${run_name}_amended_consensus.parq -r ${run_name}
    python3 ${launchDir}/bin/parquet_maker.py -f aa.fasta -o ${run_name}_amino_acid_consensus.parq -r ${run_name}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/samplesheet.csv -o ${run_name}_samplesheet.parq -r ${run_name}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/*minorindels.xlsx -o ${run_name}_indels.parq -r ${run_name}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/*minorvariants.xlsx -o ${run_name}_variants.parq -r ${run_name}
    python3 ${launchDir}/bin/parquet_maker.py -f ${params.r}/*summary.xlsx -o ${run_name}_summary.parq -r ${run_name}
    python3 ${launchDir}/bin/parquet_maker.py -p ${params.r} -r ${run_name}
    cat ${params.r}/IRMA/*/logs/run_info.txt > run_info_setup.txt
    head -n 65 run_info_setup.txt > run_info.txt
    python3 ${launchDir}/bin/parquet_maker.py -f run_info.txt -o ${run_name}_irma_config.parq -r ${run_name}
    """
}
