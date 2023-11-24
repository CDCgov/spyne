#!/usr/bin/env nextflow

/*
========================================================================================
   irma module
========================================================================================
*/

nextflow.enable.dsl=2

process sleep {
    tag {"waiting for irma to completely finish"}

    input:
    tuple val (sample), path (all)

    output:
    val (sample)

    script:
    """
    sleep 30
    """
}
