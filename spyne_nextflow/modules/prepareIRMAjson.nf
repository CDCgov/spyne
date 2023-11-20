#!/usr/bin/env nextflow

/*
========================================================================================
   prepareIRMAjson module
========================================================================================
*/

nextflow.enable.dsl=2

process prepareIRMAjson {
    tag {"Creating Plotly-Dash readable figures and tables for IRMA-SPY"}
    echo true

    input:
    val x

    output:
    val x

    script:
    """
    python3 ${launchDir}/spyne_nextflow/bin/prepareIRMAjson.py ${launchDir}/${params.outdir}/IRMA ${params.s} illumina flu
    """
}
