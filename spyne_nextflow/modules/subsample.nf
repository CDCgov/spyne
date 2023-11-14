#!/usr/bin/env nextflow

/*
========================================================================================
   subsample module
========================================================================================
*/

nextflow.enable.dsl=2

process subsample {
    tag {"subsampling"}

    publishDir "${params.outdir}/IRMA", pattern: "*.fastq", mode: 'copy'
    publishDir "${params.outdir}/logs", pattern: "*.log", mode: 'copy'

    input:
    tuple val(sample), path(R1), path(R2), val(target)

    output:
    tuple val (sample), path ('*_subsampled_R1.fastq'), path ('*_subsampled_R2.fastq'), emit: subsampled_fastq
    path '*.reformat.stdout.log', emit: subsample_log_out
    path '*.reformat.stderr.log', emit: subsample_log_err   

    script:
    """
    reformat.sh \\
        in1=${R1} \\
        in2=${R2} \\
        out1=${sample}_subsampled_R1.fastq \\
        out2=${sample}_subsampled_R2.fastq \\
        samplereadstarget=${target} \\
        tossbrokenreads \\
        1> ${sample}.reformat.stdout.log \\
        2> ${sample}.reformat.stderr.log
    """
}
