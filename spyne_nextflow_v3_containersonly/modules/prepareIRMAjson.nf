#!/usr/bin/env nextflow

/*
========================================================================================
   prepareIRMAjson module
========================================================================================
*/

nextflow.enable.dsl=2

process prepareIRMAjson {
    tag {"Creating Plotly-Dash readable figures and tables for IRMA-SPY"}
    container "spyne:latest"

    input:
    val x
    path IRMAdir
    path samplesheet

    output:
    val x

    script:
    """
    python3 /spyne/workflow/scripts/prepareIRMAjson.py ${IRMAdir} ${samplesheet} illumina flu
    """
}
