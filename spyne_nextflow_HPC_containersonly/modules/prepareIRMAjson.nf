#!/usr/bin/env nextflow

/*
========================================================================================
   prepareIRMAjson module
========================================================================================
*/

nextflow.enable.dsl=2

process prepareIRMAjson {
    tag {"Creating Plotly-Dash readable figures and tables for IRMA-SPY"}
    container "cdcgov/spyne:latest"

    input:
    val x

    output:
    val x

    script:
    """
    python3 /spyne/workflow/scripts/prepareIRMAjson.py ${params.r}/IRMA ${params.s} illumina flu
    """
}
